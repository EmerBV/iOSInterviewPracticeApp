//
//  NetworkService.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation
import Combine

// MARK: - Network Service Protocol
protocol NetworkServiceProtocol {
    func fetchPosts() -> AnyPublisher<[Post], NetworkError>
    func fetchUsers() -> AnyPublisher<[User], NetworkError>
    func createPost(_ post: CreatePostRequest) -> AnyPublisher<Post, NetworkError>
}

// MARK: - Network Service Implementation
final class NetworkService: NetworkServiceProtocol {
    
    private let session: URLSession
    private let baseURL = "https://jsonplaceholder.typicode.com"
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchPosts() -> AnyPublisher<[Post], NetworkError> {
        guard let url = URL(string: "\(baseURL)/posts") else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Post].self, decoder: JSONDecoder())
            .mapError { error in
                if error is DecodingError {
                    return NetworkError.decodingError
                } else {
                    return NetworkError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchUsers() -> AnyPublisher<[User], NetworkError> {
        guard let url = URL(string: "\(baseURL)/users") else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [User].self, decoder: JSONDecoder())
            .mapError { error in
                if error is DecodingError {
                    return NetworkError.decodingError
                } else {
                    return NetworkError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func createPost(_ post: CreatePostRequest) -> AnyPublisher<Post, NetworkError> {
        guard let url = URL(string: "\(baseURL)/posts") else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(post)
        } catch {
            return Fail(error: NetworkError.networkError(error))
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Post.self, decoder: JSONDecoder())
            .mapError { error in
                if error is DecodingError {
                    return NetworkError.decodingError
                } else {
                    return NetworkError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
}
