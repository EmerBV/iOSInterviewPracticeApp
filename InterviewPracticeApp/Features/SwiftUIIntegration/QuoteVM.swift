//
//  QuoteVM.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Quote ViewModel Protocol
protocol QuoteVMProtocol: ObservableObject {
    var quotes: [Quote] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get set }
    var searchText: String { get set }
    var selectedCategory: String { get set }
    
    func fetchQuotes()
    func fetchRandomQuote()
    func searchQuotes()
    func refreshData()
}

// MARK: - Quote ViewModel Implementation (Fixed)
final class QuoteVM: QuoteVMProtocol {
    
    // MARK: - Published Properties
    @Published var quotes: [Quote] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""
    @Published var selectedCategory: String = "all"
    
    // MARK: - Private Properties
    private let quoteService: QuoteServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var searchCancellable: AnyCancellable?
    
    // MARK: - Computed Properties
    var filteredQuotes: [Quote] {
        var filtered = quotes
        
        // Filter by category
        if selectedCategory != "all" {
            filtered = filtered.filter { quote in
                let quoteCategory = quote.category?.isEmpty == false ? quote.category : "general"
                return quoteCategory?.lowercased() == selectedCategory.lowercased()
            }
        }
        
        return filtered
    }
    
    var availableCategories: [String] {
        let categories = quotes.compactMap { quote in
            // Handle optional category and provide fallback
            return quote.category?.isEmpty == false ? quote.category : "general"
        }.unique().sorted()
        return ["all"] + categories
    }
    
    // MARK: - Initialization
    init(quoteService: QuoteServiceProtocol = QuoteService()) {
        self.quoteService = quoteService
        setupSearchDebounce()
    }
    
    // MARK: - Public Methods
    func fetchQuotes() {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        quoteService.fetchQuotes(limit: 30)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = self?.formatErrorMessage(error)
                        print("Failed to fetch quotes: \(error)")
                    }
                },
                receiveValue: { [weak self] response in
                    self?.quotes = response.quotes
                    print("Successfully fetched \(response.quotes.count) quotes")
                }
            )
            .store(in: &cancellables)
    }
    
    func fetchRandomQuote() {
        // Don't show loading for random quote to avoid UI flickering
        quoteService.fetchRandomQuote()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = self?.formatErrorMessage(error)
                        print("Failed to fetch random quote: \(error)")
                    }
                },
                receiveValue: { [weak self] quote in
                    // Insert random quote at the beginning, remove if already exists
                    if let existingIndex = self?.quotes.firstIndex(where: { $0.id == quote.id }) {
                        self?.quotes.remove(at: existingIndex)
                    }
                    self?.quotes.insert(quote, at: 0)
                    print("Successfully fetched random quote: \(quote.author)")
                }
            )
            .store(in: &cancellables)
    }
    
    func searchQuotes() {
        let trimmedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedQuery.isEmpty else {
            fetchQuotes()
            return
        }
        
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        quoteService.searchQuotes(query: trimmedQuery, limit: 30)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = self?.formatErrorMessage(error)
                        print("Failed to search quotes: \(error)")
                    }
                },
                receiveValue: { [weak self] response in
                    self?.quotes = response.quotes
                    print("Successfully searched quotes, found \(response.quotes.count) results")
                }
            )
            .store(in: &cancellables)
    }
    
    func refreshData() {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            fetchQuotes()
        } else {
            searchQuotes()
        }
    }
    
    // MARK: - Private Methods
    private func setupSearchDebounce() {
        searchCancellable = $searchText
            .debounce(for: .milliseconds(800), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                // Only trigger search if we have content and it's different
                guard let self = self else { return }
                
                let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty && !self.quotes.isEmpty {
                    // If search is cleared and we have quotes, refresh
                    self.fetchQuotes()
                } else if !trimmed.isEmpty {
                    // If we have search text, search
                    self.searchQuotes()
                }
            }
    }
    
    private func formatErrorMessage(_ error: NetworkError) -> String {
        switch error {
        case .invalidURL:
            return "URL inválida"
        case .noData:
            return "No se recibieron datos"
        case .decodingError:
            return "Error procesando datos"
        case .networkError(let underlyingError):
            if let urlError = underlyingError as? URLError {
                switch urlError.code {
                case .notConnectedToInternet:
                    return "Sin conexión a internet"
                case .timedOut:
                    return "Tiempo de espera agotado"
                default:
                    return "Error de conexión"
                }
            }
            return "Error de red"
        case .serverError(_):
            return "Error del servidor"
        case .unauthorized:
            return "No autorizado"
        case .forbidden:
            return "Acceso denegado"
        case .notFound:
            return "Recurso no encontrado"
        case .timeout:
            return "Tiempo de espera agotado"
        case .noInternetConnection:
            return "Sin conexión a internet"
        }
    }
}

// MARK: - Array Extension for Unique (Fixed)
extension Array where Element: Hashable {
    func unique() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

extension Array where Element == String {
    func unique() -> [String] {
        return Array(Set(self))
    }
}
