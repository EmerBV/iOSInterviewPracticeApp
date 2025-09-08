//
//  NetworkVM.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation
import Combine

protocol NetworkVMProtocol: AnyObject {
    var posts: [Post] { get }
    var users: [User] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    
    func fetchPosts() async
    func fetchUsers() async
    func createPost(title: String, body: String, userId: Int) async
    func refreshData() async
}

final class NetworkVM: NetworkVMProtocol, ObservableObject {
    
    // MARK: - Published Properties
    @Published var posts: [Post] = []
    @Published var users: [User] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    private let postService: PostService
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initialization
    init(postService: PostService = PostService()) {
        self.postService = postService
    }
    
    // MARK: - Methods
    func fetchPosts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedPosts = try await postService.fetchPosts()
            posts = fetchedPosts
        } catch let networkError as NetworkError {
            errorMessage = networkError.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func fetchUsers() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedUsers = try await postService.fetchUsers()
            users = fetchedUsers
        } catch let networkError as NetworkError {
            errorMessage = networkError.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func createPost(title: String, body: String, userId: Int = 1) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newPost = try await postService.createPost(title: title, body: body, userId: userId)
            posts.insert(newPost, at: 0)
        } catch let networkError as NetworkError {
            errorMessage = networkError.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func refreshData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let postsResult = postService.fetchPosts()
            async let usersResult = postService.fetchUsers()
            
            let (fetchedPosts, fetchedUsers) = try await (postsResult, usersResult)
            
            posts = fetchedPosts
            users = fetchedUsers
        } catch let networkError as NetworkError {
            errorMessage = networkError.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

// MARK: - NetworkVM Extension para UIKit (Combine)

extension NetworkVM {
    
    // MARK: - Combine Publishers para UIKit
    var postsPublisher: Published<[Post]>.Publisher { $posts }
    var usersPublisher: Published<[User]>.Publisher { $users }
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorPublisher: Published<String?>.Publisher { $errorMessage }
    
    // MARK: - Combine Methods para UIKit
    func fetchPostsWithCombine() {
        isLoading = true
        errorMessage = nil
        
        postService.fetchPostsPublisher()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] posts in
                    self?.posts = posts
                }
            )
            .store(in: &cancellables)
    }
    
    func fetchUsersWithCombine() {
        isLoading = true
        errorMessage = nil
        
        postService.fetchUsersPublisher()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] users in
                    self?.users = users
                }
            )
            .store(in: &cancellables)
    }
    
    func createPostWithCombine(title: String, body: String, userId: Int = 1) {
        isLoading = true
        errorMessage = nil
        
        postService.createPostPublisher(title: title, body: body, userId: userId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] post in
                    self?.posts.insert(post, at: 0)
                }
            )
            .store(in: &cancellables)
    }
}
