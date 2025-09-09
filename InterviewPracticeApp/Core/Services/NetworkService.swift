//
//  NetworkService.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation
import Combine

// MARK: - Network Service Protocol
protocol NetworkServiceProtocol {
    func request<T: Codable>(
        _ request: NetworkRequest,
        responseType: T.Type
    ) async throws -> T
    
    func requestPublisher<T: Codable>(
        _ request: NetworkRequest,
        responseType: T.Type
    ) -> AnyPublisher<T, NetworkError>
}

// MARK: - Network Service Implementation
final class NetworkService: NetworkServiceProtocol {
    
    // MARK: - Properties
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    // MARK: - Initialization
    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
        
        // Configure decoder
        self.decoder.dateDecodingStrategy = .iso8601
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // Configure encoder
        self.encoder.dateEncodingStrategy = .iso8601
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
    }
    
    // MARK: - Async/Await Implementation
    func request<T: Codable>(
        _ request: NetworkRequest,
        responseType: T.Type
    ) async throws -> T {
        let urlRequest = try buildURLRequest(from: request)
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            // 🐛 DEBUG: Imprimir respuesta RAW
            print("📄 Raw API Response:")
            if let jsonString = String(data: data, encoding: .utf8) {
                print(jsonString)
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.networkError(URLError(.badServerResponse))
            }
            
            try validateResponse(httpResponse)
            
            guard !data.isEmpty else {
                throw NetworkError.noData
            }
            
            do {
                let decodedObject = try decoder.decode(T.self, from: data)
                return decodedObject
            } catch {
                throw NetworkError.decodingError(error)
            }
            
        } catch let urlError as URLError {
            throw mapURLError(urlError)
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            throw NetworkError.networkError(error)
        }
    }
    
    // MARK: - Combine Implementation
    func requestPublisher<T: Codable>(
        _ request: NetworkRequest,
        responseType: T.Type
    ) -> AnyPublisher<T, NetworkError> {
        do {
            let urlRequest = try buildURLRequest(from: request)
            
            return session.dataTaskPublisher(for: urlRequest)
                .tryMap { [weak self] data, response -> Data in
                    guard let self = self else {
                        throw NetworkError.networkError(URLError(.unknown))
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw NetworkError.networkError(URLError(.badServerResponse))
                    }
                    
                    try self.validateResponse(httpResponse)
                    
                    guard !data.isEmpty else {
                        throw NetworkError.noData
                    }
                    
                    return data
                }
                .decode(type: T.self, decoder: decoder)
                .mapError { [weak self] error -> NetworkError in
                    guard let self = self else {
                        return NetworkError.networkError(error)
                    }
                    
                    if let urlError = error as? URLError {
                        return self.mapURLError(urlError)
                    } else if let decodingError = error as? DecodingError {
                        return NetworkError.decodingError(decodingError)
                    } else {
                        return NetworkError.networkError(error)
                    }
                }
                .eraseToAnyPublisher()
            
        } catch {
            return Fail(error: error as? NetworkError ?? NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
    }
}

// MARK: - Private Methods
private extension NetworkService {
    
    func buildURLRequest(from request: NetworkRequest) throws -> URLRequest {
        var components = URLComponents(string: request.baseURL + request.path)
        
        // Add query parameters for GET requests
        if request.method == .GET, let parameters = request.parameters {
            components?.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
        }
        
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.timeoutInterval = request.timeout
        
        // Add headers
        if let headers = request.headers {
            headers.forEach { key, value in
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Add default headers
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add body for non-GET requests
        if request.method != .GET {
            if let body = request.body {
                urlRequest.httpBody = body
            } else if let parameters = request.parameters {
                do {
                    urlRequest.httpBody = try JSONSerialization.data(
                        withJSONObject: parameters,
                        options: []
                    )
                } catch {
                    throw NetworkError.networkError(error)
                }
            }
        }
        
        return urlRequest
    }
    
    func validateResponse(_ response: HTTPURLResponse) throws {
        switch response.statusCode {
        case 200...299:
            break
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 400...499, 500...599:
            throw NetworkError.serverError(response.statusCode)
        default:
            throw NetworkError.networkError(URLError(.badServerResponse))
        }
    }
    
    func mapURLError(_ error: URLError) -> NetworkError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .noInternetConnection
        case .timedOut:
            return .timeout
        default:
            return .networkError(error)
        }
    }
}

