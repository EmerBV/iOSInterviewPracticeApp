//
//  NetworkRequest.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 8/9/25.
//

import Foundation

// MARK: - Network Request Protocol
protocol NetworkRequest {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
    var body: Data? { get }
    var timeout: TimeInterval { get }
}

extension NetworkRequest {
    var timeout: TimeInterval { 30.0 }
    var headers: [String: String]? { nil }
    var parameters: [String: Any]? { nil }
    var body: Data? { nil }
}
