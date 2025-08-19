//
//  FallbackQuoteService.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation
import Combine

final class FallbackQuoteService: QuoteServiceProtocol {
    
    private let primaryService: QuoteServiceProtocol
    private let fallbackService: QuoteServiceProtocol
    
    init(primaryService: QuoteServiceProtocol, fallbackService: QuoteServiceProtocol) {
        self.primaryService = primaryService
        self.fallbackService = fallbackService
    }
    
    func fetchQuotes(limit: Int) -> AnyPublisher<QuoteResponse, NetworkError> {
        return primaryService.fetchQuotes(limit: limit)
            .catch { _ in
                print("Primary service failed, using fallback service")
                return self.fallbackService.fetchQuotes(limit: limit)
            }
            .eraseToAnyPublisher()
    }
    
    func fetchRandomQuote() -> AnyPublisher<Quote, NetworkError> {
        return primaryService.fetchRandomQuote()
            .catch { _ in
                print("Primary service failed for random quote, using fallback")
                return self.fallbackService.fetchRandomQuote()
            }
            .eraseToAnyPublisher()
    }
    
    func searchQuotes(query: String, limit: Int) -> AnyPublisher<QuoteResponse, NetworkError> {
        return primaryService.searchQuotes(query: query, limit: limit)
            .catch { _ in
                print("Primary service failed for search, using fallback")
                return self.fallbackService.searchQuotes(query: query, limit: limit)
            }
            .eraseToAnyPublisher()
    }
}
