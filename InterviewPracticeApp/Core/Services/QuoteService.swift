//
//  QuoteService.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation
import Combine

// MARK: - Quote Service Protocol
protocol QuoteServiceProtocol {
    func fetchQuotes(limit: Int) -> AnyPublisher<QuoteResponse, NetworkError>
    func fetchRandomQuote() -> AnyPublisher<Quote, NetworkError>
    func searchQuotes(query: String, limit: Int) -> AnyPublisher<QuoteResponse, NetworkError>
}

// MARK: - Quote Service Implementation
final class QuoteService: QuoteServiceProtocol {
    
    private let session: URLSession
    private let baseURL = "https://dummyjson.com"
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchQuotes(limit: Int = 30) -> AnyPublisher<QuoteResponse, NetworkError> {
        guard let url = URL(string: "\(baseURL)/quotes?limit=\(limit)") else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw NetworkError.networkError(URLError(.badServerResponse))
                }
                return data
            }
            .decode(type: QuoteResponse.self, decoder: JSONDecoder())
            .mapError { error in
                print("Error fetching quotes: \(error)")
                if error is DecodingError {
                    return NetworkError.decodingError(error)
                } else {
                    return NetworkError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchRandomQuote() -> AnyPublisher<Quote, NetworkError> {
        guard let url = URL(string: "\(baseURL)/quotes/random") else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw NetworkError.networkError(URLError(.badServerResponse))
                }
                return data
            }
            .decode(type: SingleQuoteResponse.self, decoder: JSONDecoder())
            .map { $0.asQuote }
            .mapError { error in
                print("Error fetching random quote: \(error)")
                if error is DecodingError {
                    return NetworkError.decodingError(error)
                } else {
                    return NetworkError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func searchQuotes(query: String, limit: Int = 30) -> AnyPublisher<QuoteResponse, NetworkError> {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "\(baseURL)/quotes/search?q=\(encodedQuery)&limit=\(limit)") else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw NetworkError.networkError(URLError(.badServerResponse))
                }
                return data
            }
            .decode(type: QuoteResponse.self, decoder: JSONDecoder())
            .mapError { error in
                print("Error searching quotes: \(error)")
                if error is DecodingError {
                    return NetworkError.decodingError(error)
                } else {
                    return NetworkError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
}
