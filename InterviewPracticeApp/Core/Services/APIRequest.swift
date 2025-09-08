//
//  APIRequest.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 8/9/25.
//

import Foundation

// MARK: - Request Builder Helper
struct APIRequest: NetworkRequest {
    let baseURL: String
    let path: String
    let method: HTTPMethod
    let headers: [String: String]?
    let parameters: [String: Any]?
    let body: Data?
    let timeout: TimeInterval
    
    init(
        baseURL: String,
        path: String,
        method: HTTPMethod = .GET,
        headers: [String: String]? = nil,
        parameters: [String: Any]? = nil,
        body: Data? = nil,
        timeout: TimeInterval = 30.0
    ) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.headers = headers
        self.parameters = parameters
        self.body = body
        self.timeout = timeout
    }
}
