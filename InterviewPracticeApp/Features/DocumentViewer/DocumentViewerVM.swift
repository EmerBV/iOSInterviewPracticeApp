//
//  DocumentViewerVM.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation
import Combine

// MARK: - ViewModel Protocol
protocol DocumentViewerVMProtocol: AnyObject {
    var documentsPublisher: Published<[DocumentCategory: [InterviewDocument]]>.Publisher { get }
    
    func loadDocuments()
    func searchDocuments(with query: String)
    func numberOfDocuments(in category: DocumentCategory) -> Int
    func document(at index: Int, in category: DocumentCategory) -> InterviewDocument
}

// MARK: - ViewModel Implementation
final class DocumentViewerVM: DocumentViewerVMProtocol {
    
    @Published private var allDocuments: [DocumentCategory: [InterviewDocument]] = [:]
    @Published private var filteredDocuments: [DocumentCategory: [InterviewDocument]] = [:]
    
    var documentsPublisher: Published<[DocumentCategory: [InterviewDocument]]>.Publisher { $filteredDocuments }
    
    private var isSearching = false
    
    func loadDocuments() {
        let documents = createMockDocuments()
        allDocuments = documents
        filteredDocuments = documents
    }
    
    func searchDocuments(with query: String) {
        if query.isEmpty {
            filteredDocuments = allDocuments
            isSearching = false
        } else {
            isSearching = true
            var filtered: [DocumentCategory: [InterviewDocument]] = [:]
            
            for category in DocumentCategory.allCases {
                let categoryDocuments = allDocuments[category] ?? []
                let filteredCategoryDocs = categoryDocuments.filter { document in
                    document.title.localizedCaseInsensitiveContains(query) ||
                    document.description.localizedCaseInsensitiveContains(query) ||
                    document.tags.contains { $0.localizedCaseInsensitiveContains(query) }
                }
                
                if !filteredCategoryDocs.isEmpty {
                    filtered[category] = filteredCategoryDocs
                }
            }
            
            filteredDocuments = filtered
        }
    }
    
    func numberOfDocuments(in category: DocumentCategory) -> Int {
        return filteredDocuments[category]?.count ?? 0
    }
    
    func document(at index: Int, in category: DocumentCategory) -> InterviewDocument {
        return filteredDocuments[category]?[index] ?? InterviewDocument(
            title: "Error",
            fileName: "error.pdf",
            description: "Documento no encontrado",
            category: category,
            tags: [],
            difficulty: .easy
        )
    }
    
    // MARK: - Private Methods
    private func createMockDocuments() -> [DocumentCategory: [InterviewDocument]] {
        var documents: [DocumentCategory: [InterviewDocument]] = [:]
        
        // Swift Senior Documents
        documents[.swiftSenior] = [
            InterviewDocument(
                title: "Preguntas Swift Senior (2025)",
                fileName: "swift_senior_interview_questions_2025.pdf",
                description: "Guía completa con 50 preguntas avanzadas de Swift para desarrolladores senior de iOS",
                category: .swiftSenior,
                tags: ["Swift 5", "iOS Senior", "Concurrencia", "Actor", "Async/Await", "MVVM", "VIPER"],
                difficulty: .hard
            )
        ]
        
        // Swift Junior Documents
        documents[.swiftJunior] = [
            InterviewDocument(
                title: "Preguntas Swift Junior (2025)",
                fileName: "swift_junior_interview_questions_2025.pdf",
                description: "Fundamentos de Swift e iOS para desarrolladores junior con 50 preguntas esenciales",
                category: .swiftJunior,
                tags: ["Swift Básico", "iOS Junior", "Optionals", "MVC", "UIKit", "Fundamentos"],
                difficulty: .easy
            )
        ]
        
        // Additional Categories (you can add more documents here)
        documents[.architecture] = []
        documents[.designPatterns] = []
        documents[.bestPractices] = []
        
        return documents
    }
}
