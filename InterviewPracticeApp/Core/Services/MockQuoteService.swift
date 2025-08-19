//
//  MockQuoteService.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation
import Combine

final class MockQuoteService: QuoteServiceProtocol {
    
    func fetchQuotes(limit: Int) -> AnyPublisher<QuoteResponse, NetworkError> {
        let mockQuotes = [
            Quote(id: 1, quote: "The only way to do great work is to love what you do.", author: "Steve Jobs", category: "motivational"),
            Quote(id: 2, quote: "Life is what happens when you're busy making other plans.", author: "John Lennon", category: "wisdom"),
            Quote(id: 3, quote: "The future belongs to those who believe in the beauty of their dreams.", author: "Eleanor Roosevelt", category: "inspirational")
        ]
        
        let response = QuoteResponse(quotes: mockQuotes, total: mockQuotes.count, skip: 0, limit: limit)
        
        return Just(response)
            .setFailureType(to: NetworkError.self)
            .delay(for: .seconds(1), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func fetchRandomQuote() -> AnyPublisher<Quote, NetworkError> {
        let randomQuote = Quote(id: Int.random(in: 100...999),
                                quote: "Success is not final, failure is not fatal: it is the courage to continue that counts.",
                                author: "Winston Churchill",
                                category: "motivational")
        
        return Just(randomQuote)
            .setFailureType(to: NetworkError.self)
            .delay(for: .seconds(0.5), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func searchQuotes(query: String, limit: Int) -> AnyPublisher<QuoteResponse, NetworkError> {
        let mockQuotes = [
            Quote(id: 10, quote: "Search result for: \(query)", author: "Mock Author", category: "search")
        ]
        
        let response = QuoteResponse(quotes: mockQuotes, total: 1, skip: 0, limit: limit)
        
        return Just(response)
            .setFailureType(to: NetworkError.self)
            .delay(for: .seconds(0.8), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
