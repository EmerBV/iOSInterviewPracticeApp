//
//  Person.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation

struct Person {
    let id: UUID
    let name: String
    let email: String
    let age: Int
    
    init(name: String, email: String, age: Int) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.age = age
    }
}
