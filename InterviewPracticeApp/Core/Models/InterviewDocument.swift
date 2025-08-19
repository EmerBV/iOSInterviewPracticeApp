//
//  InterviewDocument.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation
import UIKit

enum DocumentCategory: String, CaseIterable {
    case swiftSenior = "swift_senior"
    case swiftJunior = "swift_junior"
    case architecture = "architecture"
    case designPatterns = "design_patterns"
    case bestPractices = "best_practices"
    
    var title: String {
        switch self {
        case .swiftSenior:
            return "Swift Senior"
        case .swiftJunior:
            return "Swift Junior"
        case .architecture:
            return "Arquitectura"
        case .designPatterns:
            return "Patrones de Diseño"
        case .bestPractices:
            return "Mejores Prácticas"
        }
    }
    
    var icon: String {
        switch self {
        case .swiftSenior:
            return "swift"
        case .swiftJunior:
            return "graduationcap"
        case .architecture:
            return "building.2"
        case .designPatterns:
            return "grid"
        case .bestPractices:
            return "checkmark.seal"
        }
    }
    
    var color: UIColor {
        switch self {
        case .swiftSenior:
            return .systemRed
        case .swiftJunior:
            return .systemGreen
        case .architecture:
            return .systemBlue
        case .designPatterns:
            return .systemPurple
        case .bestPractices:
            return .systemOrange
        }
    }
}

struct InterviewDocument {
    let id: UUID
    let title: String
    let fileName: String
    let description: String
    let category: DocumentCategory
    let tags: [String]
    let difficulty: Difficulty
    let createdAt: Date
    
    init(title: String, fileName: String, description: String, category: DocumentCategory, tags: [String], difficulty: Difficulty) {
        self.id = UUID()
        self.title = title
        self.fileName = fileName
        self.description = description
        self.category = category
        self.tags = tags
        self.difficulty = difficulty
        self.createdAt = Date()
    }
    
    var estimatedReadingTime: String {
        // Estimate reading time based on document length
        // For now, return a mock value
        switch difficulty {
        case .easy:
            return "15-20 min"
        case .medium:
            return "25-35 min"
        case .hard:
            return "40-60 min"
        }
    }
    
    var bundlePath: String? {
        return Bundle.main.path(forResource: fileName.replacingOccurrences(of: ".pdf", with: ""), ofType: "pdf")
    }
}
