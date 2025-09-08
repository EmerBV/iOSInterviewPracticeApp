//
//  PostService.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 8/9/25.
//

import Foundation
import Combine

final class PostService {
    private let networkService: NetworkServiceProtocol
    private let baseURL = "https://jsonplaceholder.typicode.com"
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    // Async/Await methods
    func fetchPosts() async throws -> PostResponse {
        let request = APIRequest(
            baseURL: baseURL,
            path: "/posts",
            method: .GET
        )
        
        return try await networkService.request(request, responseType: PostResponse.self)
    }
    
    func fetchUsers() async throws -> UserResponse {
        let request = APIRequest(
            baseURL: baseURL,
            path: "/users",
            method: .GET
        )
        
        return try await networkService.request(request, responseType: UserResponse.self)
    }
    
    func createPost(title: String, body: String) async throws -> Post {
        let parameters = ["title": title, "body": body]
        let request = APIRequest(
            baseURL: baseURL,
            path: "/posts",
            method: .POST,
            parameters: parameters
        )
        
        return try await networkService.request(request, responseType: Post.self)
    }
    
    // Combine methods
    func fetchPostsPublisher() -> AnyPublisher<PostResponse, NetworkError> {
        let request = APIRequest(
            baseURL: baseURL,
            path: "/posts",
            method: .GET
        )
        
        return networkService.requestPublisher(request, responseType: PostResponse.self)
            .eraseToAnyPublisher()
    }
    
    func fetchUsersPublisher() -> AnyPublisher<UserResponse, NetworkError> {
        let request = APIRequest(
            baseURL: baseURL,
            path: "/users",
            method: .GET
        )
        
        return networkService.requestPublisher(request, responseType: UserResponse.self)
            .eraseToAnyPublisher()
    }
    
    func createPostPublisher(title: String, body: String) -> AnyPublisher<Post, NetworkError> {
        let parameters = ["title": title, "body": body]
        let request = APIRequest(
            baseURL: baseURL,
            path: "/posts",
            method: .POST,
            parameters: parameters
        )
        
        return networkService.requestPublisher(request, responseType: Post.self)
    }
}
