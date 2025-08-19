//
//  Post.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation

struct Post: Codable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}

struct CreatePostRequest: Codable {
    let title: String
    let body: String
    let userId: Int
}
