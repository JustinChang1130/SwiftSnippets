//
//  Observing.swift
//  DJCoreApp
//
//  Created by 張啟裕 on 2023/12/28.
//  Copyright © 2023 SysJust. All rights reserved.
//

import Foundation

class AnyObserving {
    func removeListener() {}
}

extension Observing {
    struct Change<U> {
        let old: U?
        let new: U
    }
}

@propertyWrapper
class Observing<T>: AnyObserving {
    typealias Listener = (T) -> Void
    
    private var oldValue: T?
    private var value: T
    private var hardListeners = [Listener]()
    private var listener: Listener?
    
    var wrappedValue: T {
        get { return value }
        set {
            self.oldValue = value
            self.value = newValue
            self.notifyListeners(newValue)
        }
    }
    
    var projectedValue: Observing<T> {self}
    
    init(wrappedValue: T) {
        self.value = wrappedValue
    }
    
    /// 監聽資料改變時事件
    /// - Parameters:
    ///   - fireNow: 在綁定當下需要立即觸發事件請傳入 true (預設值為 true)
    ///   - listener: 資料變化時執行
    func bind(fireNow: Bool = true, _ listener: @escaping Listener) {
        self.listener = listener
        if fireNow {
            Task.detached { @MainActor in
                listener(self.value)
            }
        }
    }
    
    /// 監聽資料改變時事件（可取得新舊值）
    /// - Parameters:
    ///   - fireNow: 在綁定當下需要立即觸發事件請傳入 true (預設值為 true)
    ///   - listener: 資料變化時執行
    func bindChange(fireNow: Bool = true, _ listener: @escaping (Change<T>) -> Void) {
        self.listener = { newValue in
            listener(Change(old: self.oldValue, new: newValue))
        }
        
        if fireNow {
            Task.detached { @MainActor in
                listener(Change(old: self.oldValue, new: self.value))
            }
        }
    }
    
    /// 監聽資料改變時事件，資料改變時會優先通知 hardBind，並且執行 removeAllListener 也不會移除，使用時請謹慎
    /// - Parameters:
    ///   - fireNow: 在綁定當下需要立即觸發事件請傳入 true (預設值為 true)
    ///   - listener: 資料變化時執行
    func hardBind (fireNow: Bool = true, _ listener: @escaping Listener) {
        self.hardListeners.append(listener)
        if fireNow {
            Task.detached { @MainActor in
                listener(self.value)
            }
        }
    }
    
    /// 監聽資料改變時事件（可取得新舊值）
    /// - Parameters:
    ///   - fireNow: 在綁定當下需要立即觸發事件請傳入 true (預設值為 true)
    ///   - listener: 資料變化時執行
    func hardBindChange(fireNow: Bool = true, _ listener: @escaping (Change<T>) -> Void) {
        self.hardListeners.append({ newValue in
            listener(Change(old: self.oldValue, new: newValue))
        })
        
        if fireNow {
            Task.detached { @MainActor in
                listener(Change(old: self.oldValue, new: self.value))
            }
        }
    }
    
    /// 移除監聽事件
    override func removeListener() {
        super.removeListener()
        listener = nil
    }
    
    /// 通知所有 listeners
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
}
