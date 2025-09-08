//
//  User.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let address: Address
    let phone: String
    let website: String
    let company: Company
    
    enum CodingKeys: String, CodingKey {
        case id, name, username, email, address, phone, website, company
    }
}

struct UserResponse: Codable {
    let users: [User]
}
