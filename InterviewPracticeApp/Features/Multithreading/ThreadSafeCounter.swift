//
//  ThreadSafeCounter.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation

final class ThreadSafeCounter {
    private var _value = 0
    private let queue = DispatchQueue(label: "counter.queue")
    
    var value: Int {
        return queue.sync { _value }
    }
    
    func increment() {
        queue.sync {
            _value += 1
        }
    }
}
