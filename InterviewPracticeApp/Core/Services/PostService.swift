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
    
    // MARK: - Async/Await methods
    func fetchPosts() async throws -> [Post] {
        let request = APIRequest(
            baseURL: baseURL,
            path: "/posts",
            method: .GET
        )
        
        return try await networkService.request(request, responseType: [Post].self)
    }
    
    func fetchUsers() async throws -> [User] {
        let request = APIRequest(
            baseURL: baseURL,
            path: "/users",
            method: .GET
        )
        
        return try await networkService.request(request, responseType: [User].self)
    }
    
    func createPost(title: String, body: String, userId: Int = 1) async throws -> Post {
        let parameters = ["title": title, "body": body, "userId": userId] as [String : Any]
        let request = APIRequest(
            baseURL: baseURL,
            path: "/posts",
            method: .POST,
            parameters: parameters
        )
        
        return try await networkService.request(request, responseType: Post.self)
    }
    
    // MARK: - Combine methods
    func fetchPostsPublisher() -> AnyPublisher<[Post], NetworkError> {
        let request = APIRequest(
            baseURL: baseURL,
            path: "/posts",
            method: .GET
        )
        
        return networkService.requestPublisher(request, responseType: [Post].self)
    }
    
    func fetchUsersPublisher() -> AnyPublisher<[User], NetworkError> {
        let request = APIRequest(
            baseURL: baseURL,
            path: "/users",
            method: .GET
        )
        
        return networkService.requestPublisher(request, responseType: [User].self)
    }
    
    func createPostPublisher(title: String, body: String, userId: Int = 1) -> AnyPublisher<Post, NetworkError> {
        let parameters = ["title": title, "body": body, "userId": userId] as [String : Any]
        let request = APIRequest(
            baseURL: baseURL,
            path: "/posts",
            method: .POST,
            parameters: parameters
        )
        
        return networkService.requestPublisher(request, responseType: Post.self)
    }
}
