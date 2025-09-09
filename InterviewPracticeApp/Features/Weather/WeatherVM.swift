//
//  WeatherVM.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 20/8/25.
//

import Foundation
import Combine

/*
 // MARK: - Weather ViewModel Protocol
 protocol WeatherVMProtocol: AnyObject {
 var currentWeatherPublisher: Published<WeatherResponse?>.Publisher { get }
 var isLoadingPublisher: Published<Bool>.Publisher { get }
 var errorPublisher: PassthroughSubject<WeatherError, Never> { get }
 var citySuggestionsPublisher: Published<[Location]>.Publisher { get }
 var selectedCityPublisher: Published<String>.Publisher { get }
 
 func fetchWeather(for city: String)
 func fetchForecast(for city: String, days: Int)
 func searchCities(query: String)
 func selectCity(_ city: String)
 func refreshWeather()
 func clearError()
 }
 
 // MARK: - Weather ViewModel Implementation
 final class WeatherVM: WeatherVMProtocol {
 
 // MARK: - Published Properties
 @Published private var currentWeather: WeatherResponse?
 @Published private var isLoading: Bool = false
 @Published private var citySuggestions: [Location] = []
 @Published private var selectedCity: String = "Madrid"
 
 // MARK: - Publishers
 var currentWeatherPublisher: Published<WeatherResponse?>.Publisher { $currentWeather }
 var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
 var errorPublisher = PassthroughSubject<WeatherError, Never>()
 var citySuggestionsPublisher: Published<[Location]>.Publisher { $citySuggestions }
 var selectedCityPublisher: Published<String>.Publisher { $selectedCity }
 
 // MARK: - Dependencies
 private let weatherService: WeatherServiceProtocol
 private var cancellables = Set<AnyCancellable>()
 private var searchCancellable: AnyCancellable?
 
 // MARK: - Initialization
 // MOCK
 /*
  init(weatherService: WeatherServiceProtocol = MockWeatherService()) {
  self.weatherService = weatherService
  setupInitialData()
  }
  */
 
 // API
 init(weatherService: WeatherServiceProtocol = WeatherService()) {
 self.weatherService = weatherService
 setupInitialData()
 }
 
 // MARK: - Public Methods
 func fetchWeather(for city: String) {
 guard !isLoading else { return }
 
 isLoading = true
 selectedCity = city
 
 weatherService.fetchCurrentWeather(for: city)
 .receive(on: DispatchQueue.main)
 .sink(
 receiveCompletion: { [weak self] completion in
 self?.isLoading = false
 if case .failure(let error) = completion {
 self?.handleError(error)
 }
 },
 receiveValue: { [weak self] weather in
 self?.currentWeather = weather
 print("✅ Weather fetched successfully for \(city)")
 }
 )
 .store(in: &cancellables)
 }
 
 func fetchForecast(for city: String, days: Int = 3) {
 guard !isLoading else { return }
 
 isLoading = true
 selectedCity = city
 
 weatherService.fetchForecast(for: city, days: days)
 .receive(on: DispatchQueue.main)
 .sink(
 receiveCompletion: { [weak self] completion in
 self?.isLoading = false
 if case .failure(let error) = completion {
 self?.handleError(error)
 }
 },
 receiveValue: { [weak self] weather in
 self?.currentWeather = weather
 print("✅ Forecast fetched successfully for \(city)")
 }
 )
 .store(in: &cancellables)
 }
 
 func searchCities(query: String) {
 // Cancel previous search
 searchCancellable?.cancel()
 
 guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
 citySuggestions = []
 return
 }
 
 searchCancellable = weatherService.searchCities(query: query)
 .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
 .receive(on: DispatchQueue.main)
 .sink(
 receiveCompletion: { [weak self] completion in
 if case .failure(let error) = completion {
 self?.handleError(error)
 self?.citySuggestions = []
 }
 },
 receiveValue: { [weak self] cities in
 self?.citySuggestions = cities
 print("🔍 Found \(cities.count) cities for query: \(query)")
 }
 )
 }
 
 func selectCity(_ city: String) {
 selectedCity = city
 citySuggestions = []
 fetchForecast(for: city)
 }
 
 func refreshWeather() {
 fetchForecast(for: selectedCity)
 }
 
 func clearError() {
 // Error clearing is handled automatically by the PassthroughSubject
 }
 
 // MARK: - Private Methods
 private func setupInitialData() {
 // Fetch initial weather data for default city
 fetchForecast(for: selectedCity)
 }
 
 private func handleError(_ error: WeatherError) {
 print("❌ Weather error: \(error.localizedDescription)")
 errorPublisher.send(error)
 }
 }
 
 // MARK: - Helper Extensions
 extension WeatherVM {
 
 // MARK: - Convenience Properties
 var hasWeatherData: Bool {
 currentWeather != nil
 }
 
 var currentTemperature: String {
 guard let weather = currentWeather else { return "--°" }
 return "\(Int(weather.current.tempC))°C"
 }
 
 var currentCondition: String {
 guard let weather = currentWeather else { return "Loading..." }
 return weather.current.condition.text
 }
 
 var currentLocation: String {
 guard let weather = currentWeather else { return selectedCity }
 return "\(weather.location.name), \(weather.location.country)"
 }
 
 var forecastDays: [ForecastDay] {
 return currentWeather?.forecast.forecastday ?? []
 }
 
 // MARK: - Formatting Helpers
 func formattedDate(from dateString: String) -> String {
 let inputFormatter = DateFormatter()
 inputFormatter.dateFormat = "yyyy-MM-dd"
 
 let outputFormatter = DateFormatter()
 outputFormatter.dateFormat = "EEE, MMM d"
 outputFormatter.locale = Locale(identifier: "es_ES")
 
 guard let date = inputFormatter.date(from: dateString) else {
 return dateString
 }
 
 return outputFormatter.string(from: date)
 }
 
 func temperatureRange(for day: ForecastDay) -> String {
 let min = Int(day.day.mintempC)
 let max = Int(day.day.maxtempC)
 return "\(min)° / \(max)°"
 }
 
 func weatherIcon(for condition: WeatherCondition) -> String {
 // Map weather conditions to SF Symbols
 switch condition.code {
 case 1000: // Sunny/Clear
 return "sun.max.fill"
 case 1003: // Partly cloudy
 return "cloud.sun.fill"
 case 1006, 1009: // Cloudy/Overcast
 return "cloud.fill"
 case 1030: // Mist
 return "cloud.fog.fill"
 case 1063, 1180, 1183, 1186, 1189, 1192, 1195: // Rain
 return "cloud.rain.fill"
 case 1066, 1210, 1213, 1216, 1219, 1222, 1225: // Snow
 return "cloud.snow.fill"
 case 1087: // Thundery
 return "cloud.bolt.rain.fill"
 case 1114, 1117: // Blizzard
 return "wind.snow"
 case 1135, 1147: // Fog
 return "cloud.fog.fill"
 case 1150, 1153, 1168, 1171: // Drizzle
 return "cloud.drizzle.fill"
 case 1198, 1201, 1204, 1207: // Freezing rain
 return "cloud.sleet.fill"
 case 1237, 1261, 1264: // Ice pellets/Hail
 return "cloud.hail.fill"
 case 1273, 1276, 1279, 1282: // Thunder
 return "cloud.bolt.fill"
 default:
 return "questionmark.circle.fill"
 }
 }
 
 func humidityDescription(humidity: Int) -> String {
 switch humidity {
 case 0...30:
 return "Muy seco"
 case 31...50:
 return "Seco"
 case 51...70:
 return "Cómodo"
 case 71...85:
 return "Húmedo"
 default:
 return "Muy húmedo"
 }
 }
 
 func uvIndexDescription(uv: Double) -> String {
 switch uv {
 case 0...2:
 return "Bajo"
 case 3...5:
 return "Moderado"
 case 6...7:
 return "Alto"
 case 8...10:
 return "Muy alto"
 default:
 return "Extremo"
 }
 }
 }
 */

final class WeatherVM: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentWeather: WeatherResponse?
    @Published var isLoading: Bool = false
    @Published var citySuggestions: [Location] = []
    @Published var selectedCity: String = "Madrid"
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    private let weatherService: WeatherService
    private var cancellables: Set<AnyCancellable> = []
    private var searchCancellable: AnyCancellable?
    
    // MARK: - Initialization (SIN @MainActor)
    init(weatherService: WeatherService = WeatherService()) {
        self.weatherService = weatherService
        print("🏗️ WeatherVM initialized")
        
        // Usar Combine para inicialización (mejor para UIKit)
        fetchForecastWithCombine(for: selectedCity)
    }
    
    // MARK: - Async/Await Methods (con dispatch al main queue)
    func fetchWeather(for city: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            selectedCity = city
        }
        
        do {
            let weather = try await weatherService.fetchCurrentWeather(for: city)
            await MainActor.run {
                currentWeather = weather
                isLoading = false
            }
        } catch let weatherError as WeatherError {
            await MainActor.run {
                errorMessage = weatherError.localizedDescription
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    func fetchForecast(for city: String, days: Int = 3) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            selectedCity = city
        }
        
        do {
            let weather = try await weatherService.fetchForecast(for: city, days: days)
            await MainActor.run {
                currentWeather = weather
                isLoading = false
            }
        } catch let weatherError as WeatherError {
            await MainActor.run {
                errorMessage = weatherError.localizedDescription
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    func searchCities(query: String) async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            await MainActor.run {
                citySuggestions = []
            }
            return
        }
        
        do {
            let cities = try await weatherService.searchCities(query: query)
            await MainActor.run {
                citySuggestions = cities
            }
        } catch {
            await MainActor.run {
                citySuggestions = []
            }
        }
    }
    
    func selectCity(_ city: String) async {
        await MainActor.run {
            selectedCity = city
            citySuggestions = []
        }
        await fetchForecast(for: city)
    }
    
    func refreshWeather() async {
        await fetchForecast(for: selectedCity)
    }
}

// MARK: - WeatherVM Extension para UIKit (Combine PREFERIDO)
extension WeatherVM {
    
    // MARK: - Combine Publishers para UIKit
    var currentWeatherPublisher: Published<WeatherResponse?>.Publisher { $currentWeather }
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var citySuggestionsPublisher: Published<[Location]>.Publisher { $citySuggestions }
    var selectedCityPublisher: Published<String>.Publisher { $selectedCity }
    var errorPublisher: Published<String?>.Publisher { $errorMessage }
    
    // MARK: - Combine Methods para UIKit (RECOMENDADOS)
    func fetchWeatherWithCombine(for city: String) {
        isLoading = true
        errorMessage = nil
        selectedCity = city
        
        weatherService.fetchCurrentWeatherPublisher(for: city)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] weather in
                    self?.currentWeather = weather
                    //self?.printWeatherData() // 🐛 DEBUG: Ver datos completos
                }
            )
            .store(in: &cancellables)
    }
    
    func fetchForecastWithCombine(for city: String, days: Int = 3) {
        print("🔄 Starting forecast fetch with Combine for: \(city)")
        isLoading = true
        errorMessage = nil
        selectedCity = city
        
        weatherService.fetchForecastPublisher(for: city, days: days)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    print("🏁 Forecast fetch completed")
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print("❌ Forecast error: \(error)")
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] weather in
                    print("✅ Forecast success - has forecast: \(weather.hasForecast)")
                    self?.currentWeather = weather
                    //self?.printWeatherData() // 🐛 DEBUG: Ver datos
                    self?.printRealWeatherData() // 🐛 DEBUG: Ver datos completos
                }
            )
            .store(in: &cancellables)
    }
    
    func searchCitiesWithCombine(query: String) {
        searchCancellable?.cancel()
        
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            citySuggestions = []
            return
        }
        
        searchCancellable = weatherService.searchCitiesPublisher(query: query)
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        self?.citySuggestions = []
                    }
                },
                receiveValue: { [weak self] cities in
                    self?.citySuggestions = cities
                }
            )
    }
}

// MARK: - WeatherVM Helper Extensions
extension WeatherVM {
    
    var hasWeatherData: Bool {
        currentWeather != nil
    }
    
    var currentTemperature: String {
        guard let weather = currentWeather else { return "--°" }
        
        // 🐛 DEBUG: Ver si el problema está aquí
        if let tempC = weather.current.tempC {
            print("🌡️ Found tempC: \(tempC)")
            return "\(Int(tempC))°C"
        } else {
            print("🌡️ tempC is NIL!")
            return "--°"
        }
    }
    
    var currentCondition: String {
        guard let weather = currentWeather else { return "Loading..." }
        return weather.current.condition.text
    }
    
    var currentLocation: String {
        guard let weather = currentWeather else { return selectedCity }
        return "\(weather.location.name), \(weather.location.country)"
    }
    
    var forecastDays: [ForecastDay] {
        return currentWeather?.forecastDays ?? []
    }
    
    var currentWindSpeed: String {
        guard let weather = currentWeather else { return "--" }
        
        if let windKph = weather.current.windKph {
            print("💨 Found windKph: \(windKph)")
            return "\(Int(windKph)) km/h"
        } else {
            print("💨 windKph is NIL!")
            return "--"
        }
    }
    
    var currentHumidity: String {
        guard let weather = currentWeather else { return "--%" }
        
        if let humidity = weather.current.humidity {
            print("💧 Found humidity: \(humidity)")
            return "\(humidity)%"
        } else {
            print("💧 humidity is NIL!")
            return "--%"
        }
    }
    
    var currentFeelsLike: String {
        guard let weather = currentWeather else { return "--°" }
        
        if let feelslikeC = weather.current.feelslikeC {
            print("🌡️ Found feelslike: \(feelslikeC)")
            return "\(Int(feelslikeC))°C"
        } else {
            print("🌡️ feelslikeC is NIL!")
            return "--°"
        }
    }
    
    var currentPressure: String {
        guard let weather = currentWeather else { return "--" }
        
        if let pressureMb = weather.current.pressureMb {
            print("📊 Found pressure: \(pressureMb)")
            return "\(Int(pressureMb)) mb"
        } else {
            print("📊 pressureMb is NIL!")
            return "--"
        }
    }
    
    var currentUV: String {
        guard let weather = currentWeather else { return "--" }
        
        if let uv = weather.current.uv {
            print("☀️ Found UV: \(uv)")
            return "\(Int(uv))"
        } else {
            print("☀️ UV is NIL!")
            return "--"
        }
    }
    
    func temperatureRange(for day: ForecastDay) -> String {
        let maxTemp = day.day.maxtempC ?? 0
        let minTemp = day.day.mintempC ?? 0
        
        print("📅 Day \(day.date): maxTemp=\(day.day.maxtempC?.description ?? "NIL"), minTemp=\(day.day.mintempC?.description ?? "NIL")")
        
        return "\(Int(maxTemp))° / \(Int(minTemp))°"
    }
    
    var currentVisibility: String {
        guard let weather = currentWeather,
              let visKm = weather.current.visKm else { return "--" }
        return "\(Int(visKm)) km"
    }
    
    var currentGust: String {
        guard let weather = currentWeather else { return "--" }
        
        if let gustKph = weather.current.gustKph, gustKph > 0 {
            return "\(Int(gustKph)) km/h"
        }
        return "Sin ráfagas"
    }
    
    // MARK: - Helper Methods
    func weatherIcon(for condition: WeatherCondition) -> String {
        switch condition.code {
        case 1000: return "sun.max.fill"
        case 1003: return "cloud.sun.fill"
        case 1006, 1009: return "cloud.fill"
        case 1030, 1135, 1147: return "cloud.fog.fill"
        case 1063, 1180, 1183, 1186, 1189, 1192, 1195, 1240, 1243, 1246: return "cloud.rain.fill"
        case 1066, 1069, 1072, 1114, 1117, 1210, 1213, 1216, 1219, 1222, 1225, 1237, 1249, 1252, 1255, 1258, 1261, 1264: return "cloud.snow.fill"
        case 1087, 1273, 1276, 1279, 1282: return "cloud.bolt.rain.fill"
        default: return "cloud.fill"
        }
    }
    
    func formattedDate(from dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "EEEE"
            dateFormatter.locale = Locale(identifier: "es_ES")
            return dateFormatter.string(from: date).capitalized
        }
        
        return dateString
    }
    
    // MARK: - Debug Helper
    func printWeatherData() {
        guard let weather = currentWeather else {
            print("🚫 No weather data available")
            return
        }
        
        print("🌤️ Weather Data Debug:")
        print("📍 Location: \(weather.location.name), \(weather.location.country)")
        print("🌡️ Temperature: \(weather.current.tempC ?? 0)°C")
        print("☁️ Condition: \(weather.current.condition.text)")
        print("💨 Wind: \(weather.current.windKph ?? 0) km/h")
        print("💧 Humidity: \(weather.current.humidity)%")
        print("📊 Pressure: \(weather.current.pressureMb ?? 0) mb")
        print("☀️ UV: \(weather.current.uv)")
        print("🔮 Has Forecast: \(weather.hasForecast)")
        print("📅 Forecast Days: \(weather.forecastDays.count)")
        
        if weather.hasForecast {
            print("🗓️ Forecast Details:")
            for (index, day) in weather.forecastDays.enumerated() {
                let maxTemp = day.day.maxtempC ?? 0
                let minTemp = day.day.mintempC ?? 0
                print("  Day \(index + 1): \(day.date) - \(day.day.condition.text) - \(Int(maxTemp))°/\(Int(minTemp))°")
            }
        }
    }
    
    // MARK: - Debug Helper COMPLETO
    func printRealWeatherData() {
        guard let weather = currentWeather else {
            print("🚫 No weather data available")
            return
        }
        
        print("🌤️ REAL Weather Data Debug:")
        print("📍 Location: \(weather.location.name), \(weather.location.country)")
        
        // Current Weather - Mostrar valores REALES (no con ??)
        print("🌡️ Current Weather Fields:")
        print("  tempC: \(weather.current.tempC?.description ?? "NIL")")
        print("  tempF: \(weather.current.tempF?.description ?? "NIL")")
        print("  condition.text: '\(weather.current.condition.text)'")
        print("  condition.code: \(weather.current.condition.code)")
        print("  windKph: \(weather.current.windKph?.description ?? "NIL")")
        print("  windMph: \(weather.current.windMph?.description ?? "NIL")")
        print("  windDegree: \(weather.current.windDegree?.description ?? "NIL")")
        print("  windDir: '\(weather.current.windDir ?? "NIL")'")
        print("  pressureMb: \(weather.current.pressureMb?.description ?? "NIL")")
        print("  humidity: \(weather.current.humidity.description)")
        print("  cloud: \(weather.current.cloud.description)")
        print("  feelslikeC: \(weather.current.feelslikeC?.description ?? "NIL")")
        print("  visKm: \(weather.current.visKm?.description ?? "NIL")")
        print("  uv: \(weather.current.uv.description)")
        print("  gustKph: \(weather.current.gustKph?.description ?? "NIL")")
        print("  isDay: \(weather.current.isDay?.description ?? "NIL")")
        print("  precipMm: \(weather.current.precipMm?.description ?? "NIL")")
        
        // Forecast Data
        print("🔮 Has Forecast: \(weather.hasForecast)")
        print("📅 Forecast Days: \(weather.forecastDays.count)")
        
        if weather.hasForecast {
            print("🗓️ Forecast Details:")
            for (index, day) in weather.forecastDays.enumerated() {
                print("  Day \(index + 1): \(day.date)")
                print("    condition: '\(day.day.condition.text)'")
                print("    maxtempC: \(day.day.maxtempC?.description ?? "NIL")")
                print("    mintempC: \(day.day.mintempC?.description ?? "NIL")")
                print("    avghumidity: \(day.day.avghumidity?.description ?? "NIL")")
                print("    maxwindKph: \(day.day.maxwindKph?.description ?? "NIL")")
                print("    uv: \(day.day.uv?.description ?? "NIL")")
            }
        }
    }
    
    // MARK: - Método para agregar debug en fetchForecastWithCombine
    func debugNetworkResponse() {
        print("🔍 Adding API Response Debug to WeatherService...")
        print("💡 Add this to WeatherService.fetchForecast method:")
        print("""
            // En WeatherService.fetchForecast, después de obtener data:
            print("📄 Raw API Response for Madrid:")
            if let jsonString = String(data: data, encoding: .utf8) {
                print(jsonString)
            }
            """)
    }
}
