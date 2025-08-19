//
//  Exercise.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import UIKit

enum Difficulty: String, CaseIterable {
    case easy = "Fácil"
    case medium = "Medio"
    case hard = "Difícil"
    
    var color: UIColor {
        switch self {
        case .easy: return .systemGreen
        case .medium: return .systemOrange
        case .hard: return .systemRed
        }
    }
}

struct Exercise {
    let title: String
    let description: String
    let difficulty: Difficulty
    let tags: [String]
    let createViewController: () -> UIViewController
}
