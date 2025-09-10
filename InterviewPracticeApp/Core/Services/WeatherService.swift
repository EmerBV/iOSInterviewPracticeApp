//
//  WeatherService.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 20/8/25.
//

import Foundation
import Combine

class WeatherService {
    private let networkService: NetworkServiceProtocol
    private let baseURL = "http://api.weatherapi.com/v1"
    private let apiKey = "81e77507295a4002b39133154250809"
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    // MARK: - Async/Await methods
    func fetchCurrentWeather(for city: String) async throws -> WeatherResponse {
        print("🌤️ Fetching current weather for: \(city)")
        
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
        
        print("🔗 Request URL will be: \(baseURL)/current.json?key=\(apiKey)&q=\(city)&aqi=yes")
        
        do {
            let currentResponse = try await networkService.request(request, responseType: CurrentWeatherResponse.self)
            print("✅ Successfully decoded current weather response")
            
            return WeatherResponse(
                location: currentResponse.location,
                current: currentResponse.current,
                forecast: nil
            )
        } catch let networkError as NetworkError {
            print("❌ Network error: \(networkError)")
            throw mapNetworkError(networkError)
        } catch {
            print("❌ Unknown error: \(error)")
            throw WeatherError.networkError(error)
        }
    }
    
    func fetchForecast(for city: String, days: Int = 3) async throws -> WeatherResponse {
        print("🌤️ Fetching forecast for: \(city), days: \(days)")
        
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
        
        print("🔗 Request URL will be: \(baseURL)/forecast.json?key=\(apiKey)&q=\(city)&aqi=yes&days=\(days)")
        
        do {
            // Hacer request como Data primero
            let rawData = try await networkService.request(request, responseType: Data.self)
            
            print("📡 RAW WeatherAPI Response:")
            if let jsonString = String(data: rawData, encoding: .utf8) {
                print(jsonString)
            }
            // 🐛 AGREGAR ESTE DEBUG AQUÍ:
            print("📡 Making network request...")
            let response = try await networkService.request(request, responseType: WeatherResponse.self)
            
            // 🐛 DEBUG: Imprimir algunos valores clave
            print("✅ Successfully decoded forecast response")
            print("🌡️ Current temp from API: \(response.current.tempC?.description ?? "NIL")")
            print("💨 Wind from API: \(response.current.windKph?.description ?? "NIL")")
            print("📊 Pressure from API: \(response.current.pressureMb?.description ?? "NIL")")
            print("🗓️ Forecast days count: \(response.forecast?.forecastday.count ?? 0)")
            
            if let firstDay = response.forecast?.forecastday.first {
                print("📅 First forecast day:")
                print("  Max temp: \(firstDay.day.maxtempC?.description ?? "NIL")")
                print("  Min temp: \(firstDay.day.mintempC?.description ?? "NIL")")
            }
            
            return response
        } catch let networkError as NetworkError {
            print("❌ Network error: \(networkError)")
            throw mapNetworkError(networkError)
        } catch {
            print("❌ Unknown error: \(error)")
            throw WeatherError.networkError(error)
        }
    }
    
    func searchCities(query: String) async throws -> [Location] {
        print("🔍 Searching cities for: \(query)")
        
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
            let locations = try await networkService.request(request, responseType: [Location].self)
            print("✅ Found \(locations.count) cities")
            return locations
        } catch let networkError as NetworkError {
            print("❌ Search error: \(networkError)")
            throw mapNetworkError(networkError)
        } catch {
            print("❌ Unknown search error: \(error)")
            throw WeatherError.networkError(error)
        }
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

// MARK: - Extension for Combine methods
extension WeatherService {
    // MARK: - Combine methods para UIKit
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
}
