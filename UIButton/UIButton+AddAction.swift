//
//  UIButton+AddAction.swift
//  SwiftSnippets
//
//  Created by 張啟裕 on 2024/11/14.
//

import UIKit

extension UIButton {
    
    typealias Action = () -> Void
    
    private struct AssociatedKeys {
        static var actionClosure = UInt8()
    }
    
    // 添加一個 closure 屬性來存儲事件處理的 closure
    private var actionClosure: Action? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.actionClosure) as? (() -> Void)
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.actionClosure, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // 設置事件處理的 closure
    func addAction(for controlEvents: UIControl.Event = .touchUpInside, action: Action?) {
        self.actionClosure = action
        self.addTarget(self, action: #selector(handleAction), for: controlEvents)
    }
    
    @objc private func handleAction() {
        actionClosure?()
    }
}
