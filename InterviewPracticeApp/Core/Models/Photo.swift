//
//  Photo.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation
import UIKit

struct Photo {
    let id: UUID
    let title: String
    let color: UIColor
    let size: CGSize
    
    init(title: String, color: UIColor, size: CGSize = CGSize(width: 200, height: 200)) {
        self.id = UUID()
        self.title = title
        self.color = color
        self.size = size
    }
}
