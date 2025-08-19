//
//  ChildClassFixed.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation

class ChildClassFixed {
    weak var parent: ParentClassFixed? // Weak reference - solución al retain cycle
    
    deinit {
        print("ChildClassFixed deinit")
    }
}
