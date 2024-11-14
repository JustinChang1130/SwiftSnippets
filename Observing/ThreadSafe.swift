//
//  ThreadSafe.swift
//  NavigationCustom
//
//  Created by 張啟裕 on 2024/10/17.
//

import Foundation

@propertyWrapper
class ThreadSafe<Value> {
    private var value: Value
    private let queue = DispatchQueue(label: UUID().uuidString)
    
    init(wrappedValue: Value) {
        self.value = wrappedValue
    }
    
    var wrappedValue: Value {
        get {
            return queue.sync { value }
        }
        set {
            queue.sync { value = newValue }
        }
    }
}
