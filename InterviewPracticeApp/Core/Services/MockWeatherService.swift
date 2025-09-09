//
//  MockWeatherService.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 20/8/25.
//

import Foundation
import Combine

/*
 // MARK: - Mock Weather Service
 final class MockWeatherService: WeatherServiceProtocol {
 
 func fetchCurrentWeather(for city: String) -> AnyPublisher<WeatherResponse, WeatherError> {
 let mockResponse = createMockWeatherResponse(for: city)
 
 return Just(mockResponse)
 .setFailureType(to: WeatherError.self)
 .delay(for: .seconds(1), scheduler: RunLoop.main)
 .eraseToAnyPublisher()
 }
 
 func fetchForecast(for city: String, days: Int) -> AnyPublisher<WeatherResponse, WeatherError> {
 let mockResponse = createMockForecastResponse(for: city, days: days)
 
 return Just(mockResponse)
 .setFailureType(to: WeatherError.self)
 .delay(for: .seconds(1.5), scheduler: RunLoop.main)
 .eraseToAnyPublisher()
 }
 
 func searchCities(query: String) -> AnyPublisher<[Location], WeatherError> {
 let mockCities = createMockCities(for: query)
 
 return Just(mockCities)
 .setFailureType(to: WeatherError.self)
 .delay(for: .seconds(0.8), scheduler: RunLoop.main)
 .eraseToAnyPublisher()
 }
 
 // MARK: - Mock Data Creation
 private func createMockWeatherResponse(for city: String) -> WeatherResponse {
 let location = Location(
 name: city,
 region: "Mock Region",
 country: "Mock Country",
 lat: 40.7128,
 lon: -74.0060,
 tzId: "America/New_York",
 localtimeEpoch: Int(Date().timeIntervalSince1970),
 localtime: DateFormatter.current.string(from: Date())
 )
 
 let condition = WeatherCondition(
 text: "Sunny",
 icon: "//cdn.weatherapi.com/weather/64x64/day/116.png",
 code: 1000
 )
 
 let currentWeather = CurrentWeather(
 lastUpdatedEpoch: Int(Date().timeIntervalSince1970),
 lastUpdated: DateFormatter.current.string(from: Date()),
 tempC: 25.0,
 tempF: 77.0,
 isDay: 1,
 condition: condition,
 windMph: 10.3,
 windKph: 16.6,
 windDegree: 240,
 windDir: "WSW",
 pressureMb: 1013.0,
 pressureIn: 29.91,
 precipMm: 0.0,
 precipIn: 0.0,
 humidity: 60,
 cloud: 25,
 feelslikeC: 27.0,
 feelslikeF: 80.6,
 visKm: 16.0,
 visMiles: 9.9,
 uv: 6.0,
 gustMph: 15.0,
 gustKph: 24.1
 )
 
 let forecast = Forecast(forecastday: [])
 
 return WeatherResponse(
 location: location,
 current: currentWeather,
 forecast: forecast
 )
 }
 
 private func createMockForecastResponse(for city: String, days: Int) -> WeatherResponse {
 var mockResponse = createMockWeatherResponse(for: city)
 
 let forecastDays = (0..<days).map { dayOffset in
 let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date()) ?? Date()
 let dateString = DateFormatter.dateOnly.string(from: date)
 
 let condition = WeatherCondition(
 text: dayOffset == 0 ? "Sunny" : "Partly Cloudy",
 icon: "//cdn.weatherapi.com/weather/64x64/day/116.png",
 code: 1000
 )
 
 let dayWeather = DayWeather(
 maxtempC: 25.0 + Double(dayOffset),
 maxtempF: 77.0 + Double(dayOffset) * 1.8,
 mintempC: 15.0 + Double(dayOffset),
 mintempF: 59.0 + Double(dayOffset) * 1.8,
 avgtempC: 20.0 + Double(dayOffset),
 avgtempF: 68.0 + Double(dayOffset) * 1.8,
 maxwindMph: 15.0,
 maxwindKph: 24.1,
 totalprecipMm: 0.0,
 totalprecipIn: 0.0,
 totalsnowCm: 0.0,
 avgvisKm: 16.0,
 avgvisMiles: 9.9,
 avghumidity: 60.0,
 dailyWillItRain: 0,
 dailyChanceOfRain: 10,
 dailyWillItSnow: 0,
 dailyChanceOfSnow: 0,
 condition: condition,
 uv: 6.0
 )
 
 let astro = Astro(
 sunrise: "06:30 AM",
 sunset: "07:45 PM",
 moonrise: "10:15 PM",
 moonset: "08:30 AM",
 moonPhase: "Waxing Crescent",
 moonIllumination: "25",
 isMoonUp: 0,
 isSunUp: 1
 )
 
 return ForecastDay(
 date: dateString,
 dateEpoch: Int(date.timeIntervalSince1970),
 day: dayWeather,
 astro: astro,
 hour: []
 )
 }
 
 mockResponse = WeatherResponse(
 location: mockResponse.location,
 current: mockResponse.current,
 forecast: Forecast(forecastday: forecastDays)
 )
 
 return mockResponse
 }
 
 private func createMockCities(for query: String) -> [Location] {
 let cities = [
 "Madrid, Madrid, Spain",
 "Barcelona, Catalonia, Spain",
 "Valencia, Valencia, Spain",
 "Sevilla, Andalusia, Spain",
 "New York, New York, USA",
 "London, England, UK",
 "Paris, Île-de-France, France",
 "Tokyo, Tokyo, Japan"
 ]
 
 return cities.filter { $0.lowercased().contains(query.lowercased()) }
 .enumerated()
 .map { index, cityName in
 let components = cityName.components(separatedBy: ", ")
 return Location(
 name: components[0],
 region: components.count > 1 ? components[1] : "",
 country: components.count > 2 ? components[2] : "",
 lat: 40.0 + Double(index),
 lon: -3.0 + Double(index),
 tzId: "Europe/Madrid",
 localtimeEpoch: Int(Date().timeIntervalSince1970),
 localtime: DateFormatter.current.string(from: Date())
 )
 }
 }
 }
 
 // MARK: - Date Formatter Extensions
 private extension DateFormatter {
 static let current: DateFormatter = {
 let formatter = DateFormatter()
 formatter.dateFormat = "yyyy-MM-dd HH:mm"
 return formatter
 }()
 
 static let dateOnly: DateFormatter = {
 let formatter = DateFormatter()
 formatter.dateFormat = "yyyy-MM-dd"
 return formatter
 }()
 }
 */

class MockWeatherService: WeatherService {
    
    override func fetchCurrentWeather(for city: String) async throws -> WeatherResponse {
        print("🧪 Mock: Fetching current weather for: \(city)")
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 segundo
        return createMockWeatherResponse(for: city)
    }
    
    override func fetchForecast(for city: String, days: Int = 3) async throws -> WeatherResponse {
        print("🧪 Mock: Fetching forecast for: \(city)")
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 segundos
        return createMockForecastResponse(for: city, days: days)
    }
    
    override func searchCities(query: String) async throws -> [Location] {
        print("🧪 Mock: Searching cities for: \(query)")
        try await Task.sleep(nanoseconds: 800_000_000) // 0.8 segundos
        return createMockCities(for: query)
    }
    
    // MARK: - Mock Data Creation
    private func createMockWeatherResponse(for city: String) -> WeatherResponse {
        let location = Location(
            name: city,
            region: "Mock Region",
            country: "Mock Country",
            lat: 40.7128,
            lon: -74.0060,
            tzId: "America/New_York",
            localtimeEpoch: Int(Date().timeIntervalSince1970),
            localtime: "2025-09-09 15:30"
        )
        
        let condition = WeatherCondition(
            text: "Sunny",
            icon: "//cdn.weatherapi.com/weather/64x64/day/116.png",
            code: 1000
        )
        
        let currentWeather = CurrentWeather(
            lastUpdatedEpoch: Int(Date().timeIntervalSince1970),
            lastUpdated: "2025-09-09 15:30",
            tempC: Double.random(in: 20...30),
            tempF: Double.random(in: 68...86),
            isDay: 1,
            condition: condition,
            windMph: Double.random(in: 0...15),
            windKph: Double.random(in: 0...24),
            windDegree: Int.random(in: 0...360),
            windDir: "NW",
            pressureMb: 1013.0,
            pressureIn: 29.92,
            precipMm: 0.0,
            precipIn: 0.0,
            humidity: Int.random(in: 40...80),
            cloud: Int.random(in: 0...50),
            feelslikeC: Double.random(in: 20...32),
            feelslikeF: Double.random(in: 68...90),
            visKm: 10.0,
            visMiles: 6.0,
            uv: Double.random(in: 1...8),
            gustMph: Double.random(in: 0...20),
            gustKph: Double.random(in: 0...32)
        )
        
        return WeatherResponse(
            location: location,
            current: currentWeather,
            forecast: nil
        )
    }
    
    private func createMockForecastResponse(for city: String, days: Int) -> WeatherResponse {
        var baseResponse = createMockWeatherResponse(for: city)
        
        // Crear días de pronóstico mock
        let forecastDays = (0..<days).map { dayOffset in
            let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date()) ?? Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: date)
            
            let condition = WeatherCondition(
                text: ["Sunny", "Partly Cloudy", "Cloudy"].randomElement() ?? "Sunny",
                icon: "//cdn.weatherapi.com/weather/64x64/day/116.png",
                code: [1000, 1003, 1006].randomElement() ?? 1000
            )
            
            let dayWeather = DayWeather(
                maxtempC: Double.random(in: 25...35),
                maxtempF: Double.random(in: 77...95),
                mintempC: Double.random(in: 15...25),
                mintempF: Double.random(in: 59...77),
                avgtempC: Double.random(in: 20...30),
                avgtempF: Double.random(in: 68...86),
                maxwindMph: Double.random(in: 10...20),
                maxwindKph: Double.random(in: 16...32),
                totalprecipMm: 0.0,
                totalprecipIn: 0.0,
                totalsnowCm: 0.0,
                avgvisKm: 10.0,
                avgvisMiles: 6.0,
                avghumidity: Double.random(in: 40...80),
                dailyWillItRain: 0,
                dailyChanceOfRain: Int.random(in: 0...30),
                dailyWillItSnow: 0,
                dailyChanceOfSnow: 0,
                condition: condition,
                uv: Double.random(in: 1...8)
            )
            
            let astro = Astro(
                sunrise: "06:30",
                sunset: "19:45",
                moonrise: "20:15",
                moonset: "07:30",
                moonPhase: "Waxing Crescent",
                moonIllumination: "25",
                isMoonUp: 0,
                isSunUp: 1
            )
            
            return ForecastDay(
                date: dateString,
                dateEpoch: Int(date.timeIntervalSince1970),
                day: dayWeather,
                astro: astro,
                hour: [] // Simplificado para mock
            )
        }
        
        let forecast = Forecast(forecastday: forecastDays)
        
        return WeatherResponse(
            location: baseResponse.location,
            current: baseResponse.current,
            forecast: forecast
        )
    }
    
    private func createMockCities(for query: String) -> [Location] {
        let mockCities = [
            "\(query) City",
            "\(query) Town",
            "New \(query)",
            "\(query) Beach"
        ]
        
        return mockCities.enumerated().map { index, cityName in
            Location(
                name: cityName,
                region: "Region \(index + 1)",
                country: "Country \(index + 1)",
                lat: Double.random(in: -90...90),
                lon: Double.random(in: -180...180),
                tzId: "UTC",
                localtimeEpoch: Int(Date().timeIntervalSince1970),
                localtime: "2025-09-09 15:30"
            )
        }
    }
}
