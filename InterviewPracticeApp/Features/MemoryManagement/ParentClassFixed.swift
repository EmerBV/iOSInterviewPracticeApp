//
//  ParentClassFixed.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation

class ParentClassFixed {
    var child: ChildClassFixed?
    
    deinit {
        print("ParentClassFixed deinit")
    }
}
