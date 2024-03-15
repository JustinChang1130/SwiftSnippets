//
//  Observing.swift
//
//  Created by Justin on 2023/12/28.
//

@propertyWrapper
class Observing<T> {
    typealias Listener = (T) -> Void
    
    private var value: T
    private var hardListeners = [Listener]()
    private var listener: Listener?
    
    var wrappedValue: T {
        get { return value }
        set {
            self.value = newValue
            self.notifyListeners(newValue)
        }
    }
    
    var projectedValue: Observing<T> {self}
    
    init(wrappedValue: T) {
        self.value = wrappedValue
    }

    /// Listen to data change events.
    /// - Parameters:
    /// - fireNow: Pass true if you need to trigger the event immediately upon binding (default is true).
    /// - listener: Executed when the data changes.
    func bind(fireNow: Bool = true, _ listener: @escaping Listener) {
        self.listener = listener
        if fireNow {
            Task.detached { @MainActor in
                listener(self.value)
            }
        }
    }
    
    /// Listen to data change events. When data changes, hardBind will be notified first. Calling removeListener will not remove the hardBind listeners.
    /// - Parameters:
    /// - fireNow: Pass true if you need to trigger the event immediately upon binding (default is true).
    /// - listener: Executed when the data changes.
    func hardBind (fireNow: Bool = true, _ listener: @escaping Listener) {
        self.hardListeners.append(listener)
        if fireNow {
            Task.detached { @MainActor in
                listener(self.value)
            }
        }
    }
    
    /// Notify all listeners.
    private func notifyListeners(_ value: T) {
        for listener in hardListeners {
            Task.detached { @MainActor in
                listener(value)
            }
        }
        
        Task.detached { @MainActor in
            self.listener?(value)
        }
    }
    
    func removeListener() {
        listener = nil
    }
    
    func removeHardBindListeners() {
        hardListeners = [Listener]()
    }
    
    func removeAllListeners() {
        listener = nil
        hardListeners = [Listener]()
    }
}
