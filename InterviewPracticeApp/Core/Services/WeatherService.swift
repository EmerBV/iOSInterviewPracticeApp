//
//  WeatherService.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 20/8/25.
//

import Foundation
import Combine

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
    private let baseURL = "https://api.weatherapi.com/v1"
    
    // Nota: En una app real, esta clave debe estar en un archivo de configuración seguro
    // o obtenerse del backend. Aquí usamos una clave de ejemplo.
    private let apiKey = "demo_api_key"
    
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
