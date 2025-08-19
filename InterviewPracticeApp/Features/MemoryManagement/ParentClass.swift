//
//  ParentClass.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation

class ParentClass {
    var child: ChildClass?
    
    deinit {
        print("ParentClass deinit")
    }
}
