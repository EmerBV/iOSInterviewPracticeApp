//
//  ChildClass.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation

class ChildClass {
    var parent: ParentClass? // Strong reference - causa retain cycle
    
    deinit {
        print("ChildClass deinit")
    }
}
