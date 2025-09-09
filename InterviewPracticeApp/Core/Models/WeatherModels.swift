//
//  WeatherModels.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 20/8/25.
//

import Foundation

struct WeatherResponse: Codable {
    let location: Location
    let current: CurrentWeather
    let forecast: Forecast?
    
    init(location: Location, current: CurrentWeather, forecast: Forecast? = nil) {
        self.location = location
        self.current = current
        self.forecast = forecast
    }
}

// Modelo específico para current.json (no incluye forecast)
struct CurrentWeatherResponse: Codable {
    let location: Location
    let current: CurrentWeather
}

struct Location: Codable, Identifiable {
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    let tzId: String?              // ❌ OPCIONAL
    let localtimeEpoch: Int?       // ❌ OPCIONAL
    let localtime: String?         // ❌ OPCIONAL
    
    var id: String {
        return "\(lat)-\(lon)-\(name)"
    }
    
    enum CodingKeys: String, CodingKey {
        case name, region, country, lat, lon
        case tzId = "tz_id"
        case localtimeEpoch = "localtime_epoch"
        case localtime
    }
}

struct CurrentWeather: Codable {
    let lastUpdatedEpoch: Int?
    let lastUpdated: String?
    let tempC: Double?
    let tempF: Double?
    let isDay: Int?
    let condition: WeatherCondition
    let windMph: Double?
    let windKph: Double?
    let windDegree: Int?
    let windDir: String?
    let pressureMb: Double?
    let pressureIn: Double?
    let precipMm: Double?
    let precipIn: Double?
    let humidity: Int
    let cloud: Int
    let feelslikeC: Double?
    let feelslikeF: Double?
    let visKm: Double?
    let visMiles: Double?
    let uv: Double
    let gustMph: Double?
    let gustKph: Double?
    
    enum CodingKeys: String, CodingKey {
        case lastUpdatedEpoch = "last_updated_epoch"
        case lastUpdated = "last_updated"
        case tempC = "temp_c"
        case tempF = "temp_f"
        case isDay = "is_day"
        case condition
        case windMph = "wind_mph"
        case windKph = "wind_kph"
        case windDegree = "wind_degree"
        case windDir = "wind_dir"
        case pressureMb = "pressure_mb"
        case pressureIn = "pressure_in"
        case precipMm = "precip_mm"
        case precipIn = "precip_in"
        case humidity, cloud
        case feelslikeC = "feelslike_c"
        case feelslikeF = "feelslike_f"
        case visKm = "vis_km"
        case visMiles = "vis_miles"
        case uv
        case gustMph = "gust_mph"
        case gustKph = "gust_kph"
    }
}

struct WeatherCondition: Codable {
    let text: String
    let icon: String
    let code: Int
}

struct Forecast: Codable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Codable, Identifiable {
    let date: String
    let dateEpoch: Int?             // ❌ OPCIONAL
    let day: DayWeather
    let astro: Astro?               // ❌ OPCIONAL
    let hour: [HourWeather]?        // ❌ OPCIONAL
    
    var id: String { date }
    
    enum CodingKeys: String, CodingKey {
        case date
        case dateEpoch = "date_epoch"
        case day, astro, hour
    }
}

struct DayWeather: Codable {
    let maxtempC: Double?           // ❌ OPCIONAL
    let maxtempF: Double?           // ❌ OPCIONAL
    let mintempC: Double?           // ❌ OPCIONAL
    let mintempF: Double?           // ❌ OPCIONAL
    let avgtempC: Double?           // ❌ OPCIONAL
    let avgtempF: Double?           // ❌ OPCIONAL
    let maxwindMph: Double?         // ❌ OPCIONAL
    let maxwindKph: Double?         // ❌ OPCIONAL
    let totalprecipMm: Double?      // ❌ OPCIONAL
    let totalprecipIn: Double?      // ❌ OPCIONAL
    let totalsnowCm: Double?        // ❌ OPCIONAL
    let avgvisKm: Double?           // ❌ OPCIONAL
    let avgvisMiles: Double?        // ❌ OPCIONAL
    let avghumidity: Double?        // ❌ OPCIONAL
    let dailyWillItRain: Int?       // ❌ OPCIONAL
    let dailyChanceOfRain: Int?     // ❌ OPCIONAL
    let dailyWillItSnow: Int?       // ❌ OPCIONAL
    let dailyChanceOfSnow: Int?     // ❌ OPCIONAL
    let condition: WeatherCondition
    let uv: Double?                 // ❌ OPCIONAL
    
    enum CodingKeys: String, CodingKey {
        case maxtempC = "maxtemp_c"
        case maxtempF = "maxtemp_f"
        case mintempC = "mintemp_c"
        case mintempF = "mintemp_f"
        case avgtempC = "avgtemp_c"
        case avgtempF = "avgtemp_f"
        case maxwindMph = "maxwind_mph"
        case maxwindKph = "maxwind_kph"
        case totalprecipMm = "totalprecip_mm"
        case totalprecipIn = "totalprecip_in"
        case totalsnowCm = "totalsnow_cm"
        case avgvisKm = "avgvis_km"
        case avgvisMiles = "avgvis_miles"
        case avghumidity
        case dailyWillItRain = "daily_will_it_rain"
        case dailyChanceOfRain = "daily_chance_of_rain"
        case dailyWillItSnow = "daily_will_it_snow"
        case dailyChanceOfSnow = "daily_chance_of_snow"
        case condition, uv
    }
}

struct Astro: Codable {
    let sunrise: String?
    let sunset: String?
    let moonrise: String?
    let moonset: String?
    let moonPhase: String?
    let moonIllumination: String?
    let isMoonUp: Int?
    let isSunUp: Int?
    
    enum CodingKeys: String, CodingKey {
        case sunrise, sunset, moonrise, moonset
        case moonPhase = "moon_phase"
        case moonIllumination = "moon_illumination"
        case isMoonUp = "is_moon_up"
        case isSunUp = "is_sun_up"
    }
}

struct HourWeather: Codable, Identifiable {
    let timeEpoch: Int?
    let time: String
    let tempC: Double?
    let tempF: Double?
    let isDay: Int?
    let condition: WeatherCondition
    let windMph: Double?
    let windKph: Double?
    let windDegree: Int?
    let windDir: String?
    let pressureMb: Double?
    let pressureIn: Double?
    let precipMm: Double?
    let precipIn: Double?
    let humidity: Int?
    let cloud: Int?
    let feelslikeC: Double?
    let feelslikeF: Double?
    let windchillC: Double?
    let windchillF: Double?
    let heatindexC: Double?
    let heatindexF: Double?
    let dewpointC: Double?
    let dewpointF: Double?
    let willItRain: Int?
    let chanceOfRain: Int?
    let willItSnow: Int?
    let chanceOfSnow: Int?
    let visKm: Double?
    let visMiles: Double?
    let gustMph: Double?
    let gustKph: Double?
    let uv: Double?
    
    var id: String { time }
    
    enum CodingKeys: String, CodingKey {
        case timeEpoch = "time_epoch"
        case time
        case tempC = "temp_c"
        case tempF = "temp_f"
        case isDay = "is_day"
        case condition
        case windMph = "wind_mph"
        case windKph = "wind_kph"
        case windDegree = "wind_degree"
        case windDir = "wind_dir"
        case pressureMb = "pressure_mb"
        case pressureIn = "pressure_in"
        case precipMm = "precip_mm"
        case precipIn = "precip_in"
        case humidity, cloud
        case feelslikeC = "feelslike_c"
        case feelslikeF = "feelslike_f"
        case windchillC = "windchill_c"
        case windchillF = "windchill_f"
        case heatindexC = "heatindex_c"
        case heatindexF = "heatindex_f"
        case dewpointC = "dewpoint_c"
        case dewpointF = "dewpoint_f"
        case willItRain = "will_it_rain"
        case chanceOfRain = "chance_of_rain"
        case willItSnow = "will_it_snow"
        case chanceOfSnow = "chance_of_snow"
        case visKm = "vis_km"
        case visMiles = "vis_miles"
        case gustMph = "gust_mph"
        case gustKph = "gust_kph"
        case uv
    }
}

// MARK: - Helper Extensions
extension WeatherResponse {
    var forecastDays: [ForecastDay] {
        return forecast?.forecastday ?? []
    }
    
    var hasForecast: Bool {
        return forecast != nil && !forecastDays.isEmpty
    }
}

// MARK: - Error Model
enum WeatherError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case apiError(String)
    case networkError(Error)
    case invalidAPIKey
    case locationNotFound
    case tooManyRequests
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .noData:
            return "No se recibieron datos"
        case .decodingError(let error):
            return "Error al procesar los datos: \(error.localizedDescription)"
        case .apiError(let message):
            return "Error de API: \(message)"
        case .networkError(let error):
            return "Error de conexión: \(error.localizedDescription)"
        case .invalidAPIKey:
            return "Clave de API inválida"
        case .locationNotFound:
            return "Ubicación no encontrada"
        case .tooManyRequests:
            return "Demasiadas peticiones. Intenta más tarde."
        }
    }
}
