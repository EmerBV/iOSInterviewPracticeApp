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
    
    /*
    func fetchForecastPublisher(for city: String, days: Int = 3) -> AnyPublisher<WeatherResponse, WeatherError> {
        print("🔄 COMBINE DIRECT: Starting forecast publisher for: \(city)")
        
        // Construir URL directamente
        var components = URLComponents(string: "\(baseURL)/forecast.json")!
        components.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "aqi", value: "yes"),
            URLQueryItem(name: "days", value: "\(days)")
        ]
        
        guard let url = components.url else {
            print("❌ COMBINE DIRECT: Failed to create URL")
            return Fail(error: WeatherError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        print("🔗 COMBINE DIRECT URL: \(url.absoluteString)")
        
        // Usar URLSession directamente sin NetworkService
        return URLSession.shared.dataTaskPublisher(for: url)
            .handleEvents(
                receiveOutput: { data, response in
                    print("📡 COMBINE DIRECT: Received response")
                    print("📦 COMBINE DIRECT: Data length: \(data.count) bytes")
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        print("📊 COMBINE DIRECT: HTTP Status: \(httpResponse.statusCode)")
                    }
                }
            )
            .map(\.data) // Extraer solo los datos
            .tryMap { data -> WeatherResponse in
                print("🔄 COMBINE DIRECT: Starting decode...")
                
                // Debug: Mostrar JSON RAW
                if let jsonString = String(data: data, encoding: .utf8) {
                    let preview = String(jsonString.prefix(200))
                    print("📄 COMBINE DIRECT JSON Preview: \(preview)...")
                }
                
                // Crear decoder limpio
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                // ✅ NO usar keyDecodingStrategy
                
                do {
                    let response = try decoder.decode(WeatherResponse.self, from: data)
                    
                    print("✅ COMBINE DIRECT: Decode SUCCESS!")
                    print("🔍 COMBINE DIRECT Decoded values:")
                    print("  tempC: \(response.current.tempC?.description ?? "NIL")")
                    print("  windKph: \(response.current.windKph?.description ?? "NIL")")
                    print("  pressureMb: \(response.current.pressureMb?.description ?? "NIL")")
                    print("  humidity: \(response.current.humidity.description)")
                    print("  cloud: \(response.current.cloud.description)")
                    print("  uv: \(response.current.uv.description)")
                    
                    if let firstDay = response.forecast?.forecastday.first {
                        print("📅 COMBINE DIRECT Forecast:")
                        print("  maxtemp: \(firstDay.day.maxtempC?.description ?? "NIL")")
                        print("  mintemp: \(firstDay.day.mintempC?.description ?? "NIL")")
                    }
                    
                    return response
                    
                } catch let decodingError {
                    print("❌ COMBINE DIRECT DECODING ERROR:")
                    print("Error: \(decodingError)")
                    
                    if let decodingError = decodingError as? DecodingError {
                        switch decodingError {
                        case .keyNotFound(let key, let context):
                            print("🔑 DIRECT - Key not found: \(key.stringValue)")
                            print("📍 DIRECT - Path: \(context.codingPath.map { $0.stringValue })")
                            print("📋 DIRECT - Debug: \(context.debugDescription)")
                            
                            // Mostrar las claves disponibles si es posible
                            if let data = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                                if context.codingPath.isEmpty {
                                    print("🔍 DIRECT - Available root keys: \(Array(data.keys))")
                                }
                            }
                            
                        case .typeMismatch(let type, let context):
                            print("🔄 DIRECT - Type mismatch: expected \(type)")
                            print("📍 DIRECT - Path: \(context.codingPath.map { $0.stringValue })")
                            print("📋 DIRECT - Debug: \(context.debugDescription)")
                            
                        case .valueNotFound(let type, let context):
                            print("❓ DIRECT - Value not found: \(type)")
                            print("📍 DIRECT - Path: \(context.codingPath.map { $0.stringValue })")
                            
                        case .dataCorrupted(let context):
                            print("💥 DIRECT - Data corrupted")
                            print("📍 DIRECT - Path: \(context.codingPath.map { $0.stringValue })")
                            
                        @unknown default:
                            print("🤷‍♂️ DIRECT - Unknown decoding error")
                        }
                    }
                    
                    throw decodingError
                }
            }
            .mapError { error -> WeatherError in
                print("🔄 COMBINE DIRECT: Final error mapping: \(error)")
                
                if let urlError = error as? URLError {
                    return WeatherError.networkError(urlError)
                } else if let decodingError = error as? DecodingError {
                    return WeatherError.decodingError(decodingError)
                } else {
                    return WeatherError.networkError(error)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
     */
    
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
