//
//  NetworkVM.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation
import Combine

/*
 //#if canImport(Combine)
 // MARK: - ViewModel Protocol
 protocol NetworkVMProtocol: AnyObject {
 var postsPublisher: Published<[Post]>.Publisher { get }
 var usersPublisher: Published<[User]>.Publisher { get }
 var isLoadingPublisher: Published<Bool>.Publisher { get }
 var errorPublisher: PassthroughSubject<NetworkError, Never> { get }
 
 func fetchPosts()
 func fetchUsers()
 func createPost(title: String, body: String, userId: Int)
 func refreshData()
 }
 
 // MARK: - ViewModel Implementation
 final class NetworkVM: NetworkVMProtocol {
 
 // MARK: - Published Properties
 @Published private var posts: [Post] = []
 @Published private var users: [User] = []
 @Published private var isLoading: Bool = false
 
 var postsPublisher: Published<[Post]>.Publisher { $posts }
 var usersPublisher: Published<[User]>.Publisher { $users }
 var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
 var errorPublisher = PassthroughSubject<NetworkError, Never>()
 
 // MARK: - Dependencies
 private let networkService: NetworkServiceProtocol
 private var cancellables = Set<AnyCancellable>()
 
 // MARK: - Initialization
 init(networkService: NetworkServiceProtocol = NetworkService()) {
 self.networkService = networkService
 }
 
 // MARK: - Methods
 func fetchPosts() {
 isLoading = true
 
 networkService.fetchPosts()
 .receive(on: DispatchQueue.main)
 .sink(
 receiveCompletion: { [weak self] completion in
 self?.isLoading = false
 if case .failure(let error) = completion {
 self?.errorPublisher.send(error)
 }
 },
 receiveValue: { [weak self] posts in
 self?.posts = posts
 }
 )
 .store(in: &cancellables)
 }
 
 func fetchUsers() {
 isLoading = true
 
 networkService.fetchUsers()
 .receive(on: DispatchQueue.main)
 .sink(
 receiveCompletion: { [weak self] completion in
 self?.isLoading = false
 if case .failure(let error) = completion {
 self?.errorPublisher.send(error)
 }
 },
 receiveValue: { [weak self] users in
 self?.users = users
 }
 )
 .store(in: &cancellables)
 }
 
 func createPost(title: String, body: String, userId: Int) {
 isLoading = true
 
 let newPost = CreatePostRequest(title: title, body: body, userId: userId)
 
 networkService.createPost(newPost)
 .receive(on: DispatchQueue.main)
 .sink(
 receiveCompletion: { [weak self] completion in
 self?.isLoading = false
 if case .failure(let error) = completion {
 self?.errorPublisher.send(error)
 }
 },
 receiveValue: { [weak self] post in
 self?.posts.insert(post, at: 0)
 }
 )
 .store(in: &cancellables)
 }
 
 func refreshData() {
 // Fetch both posts and users concurrently
 isLoading = true
 
 Publishers.Zip(
 networkService.fetchPosts(),
 networkService.fetchUsers()
 )
 .receive(on: DispatchQueue.main)
 .sink(
 receiveCompletion: { [weak self] completion in
 self?.isLoading = false
 if case .failure(let error) = completion {
 self?.errorPublisher.send(error)
 }
 },
 receiveValue: { [weak self] posts, users in
 self?.posts = posts
 self?.users = users
 }
 )
 .store(in: &cancellables)
 }
 }
 */

@MainActor
final class NetworkVM: ObservableObject {
    @Published var posts: [Post] = []
    @Published var users: [User] = []
    @Published var isLoading: Bool = false
    
    private let networkService: NetworkServiceProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
}
