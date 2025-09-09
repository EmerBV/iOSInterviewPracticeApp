//
//  NetworkError.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case networkError(Error)
    case serverError(Int)
    case unauthorized
    case forbidden
    case notFound
    case timeout
    case noInternetConnection
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .unauthorized:
            return "Unauthorized access"
        case .forbidden:
            return "Forbidden access"
        case .notFound:
            return "Resource not found"
        case .timeout:
            return "Request timeout"
        case .noInternetConnection:
            return "No internet connection"
        }
    }
}

extension NetworkError {
    var asWeatherError: WeatherError {
        switch self {
        case .invalidURL:
            return .invalidURL
        case .noData:
            return .noData
        case .decodingError:
            return .decodingError
        case .networkError(let error):
            return .networkError(error)
        case .serverError(let code):
            return .apiError("Server error: \(code)")
        case .unauthorized:
            return .apiError("Unauthorized")
        case .forbidden:
            return .apiError("Forbidden")
        case .notFound:
            return .apiError("Not found")
        case .timeout:
            return .networkError(URLError(.timedOut))
        case .noInternetConnection:
            return .networkError(URLError(.notConnectedToInternet))
        }
    }
}
