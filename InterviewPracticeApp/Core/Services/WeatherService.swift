//
//  WeatherService.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 20/8/25.
//

import Foundation
import Combine

/*
 // MARK: - Weather Service Protocol
 protocol WeatherServiceProtocol {
 func fetchCurrentWeather(for city: String) -> AnyPublisher<WeatherResponse, WeatherError>
 func fetchForecast(for city: String, days: Int) -> AnyPublisher<WeatherResponse, WeatherError>
 func searchCities(query: String) -> AnyPublisher<[Location], WeatherError>
 }
 
 // MARK: - Weather Service Implementation
 final class WeatherService: WeatherServiceProtocol {
 
 // MARK: - Properties
 private let session: URLSession
 private let baseURL = "http://api.weatherapi.com/v1"
 
 // Nota: En una app real, esta clave debe estar en un archivo de configuración seguro
 // o obtenerse del backend. Aquí usamos una clave de ejemplo.
 private let apiKey = "81e77507295a4002b39133154250809"
 
 // MARK: - Initialization
 init(session: URLSession = .shared) {
 self.session = session
 }
 
 // MARK: - Public Methods
 func fetchCurrentWeather(for city: String) -> AnyPublisher<WeatherResponse, WeatherError> {
 guard let url = buildURL(endpoint: "current.json", city: city) else {
 return Fail(error: WeatherError.invalidURL)
 .eraseToAnyPublisher()
 }
 
 return performRequest(url: url)
 }
 
 func fetchForecast(for city: String, days: Int = 3) -> AnyPublisher<WeatherResponse, WeatherError> {
 guard let url = buildURL(endpoint: "forecast.json", city: city, days: days) else {
 return Fail(error: WeatherError.invalidURL)
 .eraseToAnyPublisher()
 }
 
 return performRequest(url: url)
 }
 
 func searchCities(query: String) -> AnyPublisher<[Location], WeatherError> {
 guard let url = buildSearchURL(query: query) else {
 return Fail(error: WeatherError.invalidURL)
 .eraseToAnyPublisher()
 }
 
 return session.dataTaskPublisher(for: url)
 .tryMap { data, response -> Data in
 try self.validateResponse(data: data, response: response)
 return data
 }
 .decode(type: [Location].self, decoder: JSONDecoder())
 .mapError { error in
 self.mapError(error)
 }
 .eraseToAnyPublisher()
 }
 
 // MARK: - Private Methods
 private func buildURL(endpoint: String, city: String, days: Int? = nil) -> URL? {
 var components = URLComponents(string: "\(baseURL)/\(endpoint)")
 
 var queryItems = [
 URLQueryItem(name: "key", value: apiKey),
 URLQueryItem(name: "q", value: city),
 URLQueryItem(name: "aqi", value: "yes")
 ]
 
 if let days = days {
 queryItems.append(URLQueryItem(name: "days", value: "\(days)"))
 }
 
 components?.queryItems = queryItems
 return components?.url
 }
 
 private func buildSearchURL(query: String) -> URL? {
 var components = URLComponents(string: "\(baseURL)/search.json")
 components?.queryItems = [
 URLQueryItem(name: "key", value: apiKey),
 URLQueryItem(name: "q", value: query)
 ]
 return components?.url
 }
 
 private func performRequest(url: URL) -> AnyPublisher<WeatherResponse, WeatherError> {
 return session.dataTaskPublisher(for: url)
 .tryMap { data, response -> Data in
 try self.validateResponse(data: data, response: response)
 return data
 }
 .decode(type: WeatherResponse.self, decoder: JSONDecoder())
 .mapError { error in
 self.mapError(error)
 }
 .eraseToAnyPublisher()
 }
 
 private func validateResponse(data: Data, response: URLResponse) throws -> Data {
 guard let httpResponse = response as? HTTPURLResponse else {
 throw WeatherError.networkError(URLError(.badServerResponse))
 }
 
 guard 200...299 ~= httpResponse.statusCode else {
 // Try to decode error response
 if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
 let error = errorData["error"] as? [String: Any],
 let message = error["message"] as? String {
 throw WeatherError.apiError(message)
 }
 throw WeatherError.apiError("HTTP \(httpResponse.statusCode)")
 }
 
 return data
 }
 
 private func mapError(_ error: Error) -> WeatherError {
 if let weatherError = error as? WeatherError {
 return weatherError
 } else if error is DecodingError {
 return .decodingError
 } else {
 return .networkError(error)
 }
 }
 }
 */

final class WeatherService {
    private let networkService: NetworkServiceProtocol
    private let baseURL = "http://api.weatherapi.com/v1"
    private let apiKey = "81e77507295a4002b39133154250809"
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    // MARK: - Async/Await methods
    func fetchCurrentWeather(for city: String) async throws -> WeatherResponse {
        let request = APIRequest(
            baseURL: baseURL,
            path: "/current.json",
            method: .GET,
            parameters: [
                "key": apiKey,
                "q": city,
                "aqi": "yes"
            ]
        )
        
        do {
            let currentResponse = try await networkService.request(request, responseType: CurrentWeatherResponse.self)
            return WeatherResponse(
                location: currentResponse.location,
                current: currentResponse.current,
                forecast: nil
            )
        } catch let networkError as NetworkError {
            throw mapNetworkError(networkError)
        }
    }
    
    func fetchForecast(for city: String, days: Int = 3) async throws -> WeatherResponse {
        let request = APIRequest(
            baseURL: baseURL,
            path: "/forecast.json",
            method: .GET,
            parameters: [
                "key": apiKey,
                "q": city,
                "aqi": "yes",
                "days": days
            ]
        )
        
        do {
            return try await networkService.request(request, responseType: WeatherResponse.self)
        } catch let networkError as NetworkError {
            throw mapNetworkError(networkError)
        }
    }
    
    func searchCities(query: String) async throws -> [Location] {
        let request = APIRequest(
            baseURL: baseURL,
            path: "/search.json",
            method: .GET,
            parameters: [
                "key": apiKey,
                "q": query
            ]
        )
        
        do {
            return try await networkService.request(request, responseType: [Location].self)
        } catch let networkError as NetworkError {
            throw mapNetworkError(networkError)
        }
    }
    
    // MARK: - Combine methods
    func fetchCurrentWeatherPublisher(for city: String) -> AnyPublisher<WeatherResponse, WeatherError> {
        let request = APIRequest(
            baseURL: baseURL,
            path: "/current.json",
            method: .GET,
            parameters: [
                "key": apiKey,
                "q": city,
                "aqi": "yes"
            ]
        )
        
        return networkService.requestPublisher(request, responseType: CurrentWeatherResponse.self)
            .map { currentResponse in
                WeatherResponse(
                    location: currentResponse.location,
                    current: currentResponse.current,
                    forecast: nil
                )
            }
            .mapError(mapNetworkError)
            .eraseToAnyPublisher()
    }
    
    func fetchForecastPublisher(for city: String, days: Int = 3) -> AnyPublisher<WeatherResponse, WeatherError> {
        let request = APIRequest(
            baseURL: baseURL,
            path: "/forecast.json",
            method: .GET,
            parameters: [
                "key": apiKey,
                "q": city,
                "aqi": "yes",
                "days": days
            ]
        )
        
        return networkService.requestPublisher(request, responseType: WeatherResponse.self)
            .mapError(mapNetworkError)
            .eraseToAnyPublisher()
    }
    
    func searchCitiesPublisher(query: String) -> AnyPublisher<[Location], WeatherError> {
        let request = APIRequest(
            baseURL: baseURL,
            path: "/search.json",
            method: .GET,
            parameters: [
                "key": apiKey,
                "q": query
            ]
        )
        
        return networkService.requestPublisher(request, responseType: [Location].self)
            .mapError(mapNetworkError)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Error Mapping
    private func mapNetworkError(_ networkError: NetworkError) -> WeatherError {
        switch networkError {
        case .invalidURL:
            return .invalidURL
        case .noData:
            return .noData
        case .decodingError(let error):
            return .decodingError(error)
        case .networkError(let error):
            return .networkError(error)
        case .serverError(let code):
            switch code {
            case 401:
                return .invalidAPIKey
            case 400:
                return .locationNotFound
            case 429:
                return .tooManyRequests
            default:
                return .apiError("Server error: \(code)")
            }
        case .unauthorized:
            return .invalidAPIKey
        case .forbidden:
            return .invalidAPIKey
        case .notFound:
            return .locationNotFound
        case .timeout:
            return .networkError(URLError(.timedOut))
        case .noInternetConnection:
            return .networkError(URLError(.notConnectedToInternet))
        }
    }
}
