//
//  Constants.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import UIKit

struct Constants {
    
    // MARK: - App Information
    struct App {
        static let name = "iOS Interview Practice App"
        static let version = "1.0"
        static let bundleIdentifier = "com.emerbv.InterviewPracticeApp"
    }
    
    // MARK: - Layout Constants
    struct Layout {
        static let standardSpacing: CGFloat = 16
        static let smallSpacing: CGFloat = 8
        static let largeSpacing: CGFloat = 24
        static let cornerRadius: CGFloat = 12
        static let buttonHeight: CGFloat = 44
        static let cellHeight: CGFloat = 80
    }
    
    // MARK: - Animation Constants
    struct Animation {
        static let defaultDuration: TimeInterval = 0.3
        static let fastDuration: TimeInterval = 0.15
        static let slowDuration: TimeInterval = 0.6
        static let springDamping: CGFloat = 0.8
        static let springVelocity: CGFloat = 0.5
    }
    
    // MARK: - Network Constants
    struct Network {
        static let baseURL = "https://jsonplaceholder.typicode.com"
        static let timeoutInterval: TimeInterval = 30.0
    }
    
    // MARK: - Core Data Constants
    struct CoreData {
        static let modelName = "DataModel"
        static let storeType = "sqlite"
    }
}
