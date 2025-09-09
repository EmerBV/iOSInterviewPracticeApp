//
//  MockWeatherService.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 20/8/25.
//

import Foundation
import Combine

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
                moonIllumination: 25,
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
