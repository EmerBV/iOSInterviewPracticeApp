//
//  Quote.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation

// MARK: - Quote Model
struct Quote: Codable, Identifiable {
    let id: Int
    let quote: String
    let author: String
    let category: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case quote
        case author
        case category
    }
    
    // Custom initializer for fallback
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        quote = try container.decode(String.self, forKey: .quote)
        author = try container.decode(String.self, forKey: .author)
        
        // Category might not exist in all responses
        category = try container.decodeIfPresent(String.self, forKey: .category) ?? "general"
    }
    
    // Manual initializer
    init(id: Int, quote: String, author: String, category: String = "general") {
        self.id = id
        self.quote = quote
        self.author = author
        self.category = category
    }
}

// MARK: - Quote Response
struct QuoteResponse: Codable {
    let quotes: [Quote]
    let total: Int
    let skip: Int
    let limit: Int
}

// MARK: - Single Quote Response (for random quote)
struct SingleQuoteResponse: Codable {
    let id: Int
    let quote: String
    let author: String
    let category: String?
    
    var asQuote: Quote {
        return Quote(id: id, quote: quote, author: author, category: category ?? "general")
    }
}
