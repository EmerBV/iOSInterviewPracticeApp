//
//  CoreDataError.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation

enum CoreDataError: Error, LocalizedError {
    case saveFailed
    case fetchFailed
    case deleteFailed
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .saveFailed: return "Error al guardar"
        case .fetchFailed: return "Error al obtener datos"
        case .deleteFailed: return "Error al eliminar"
        case .notFound: return "Elemento no encontrado"
        }
    }
}
