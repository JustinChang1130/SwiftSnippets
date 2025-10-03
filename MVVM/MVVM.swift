//
//  MVVM.swift
//  MVVMDemo
//
//  Created by 張啟裕 on 2025/8/15.
//

import UIKit

protocol ViewModelProtocol: AnyObject {}

private var AssociatedKeys: UInt8 = 0

extension ViewModelProtocol {
    
    /// 如果你 RowViewModel 命名是 cellName + viewModel 可以直接用這方法直接取得 cell Name
    var cellName: String {
        var name = String(describing: Self.self)
        let suffix = "ViewModel"
        if name.hasSuffix(suffix) {
            let endIndex = name.index(name.endIndex, offsetBy: -suffix.count)
            name = String(name[..<endIndex])
            return name
        } else {
            fatalError("使用 \(#function) 命名未依規則使用 cell名稱 加上 ViewModel")
        }
    }
    
    /// 提供 conform ViewModelProtocol 的 model init 其對應的 UIView (ViewModelConfigurable)
    /// 假設你有一個名為 SomeViewModel 的 class 的實體，使用此計算屬性
    /// 他會在相同的 bundle 找出名為 SomeView 的 UIView class 並實體化後與 viewModel 綁定後回傳
    var view: UIView {
        
        // 取得當前模組名稱
        if let cachedView = objc_getAssociatedObject(self, &AssociatedKeys) as? UIView {
            if let configurable = cachedView as? (any ViewModelConfigurable) {
                configurable.configure(by: self)
            }
            return cachedView
        }
        
        let currentBundle = Bundle(for: Self.self)
        guard let namespace = currentBundle.namespace else {
            return UIView()
        }
        
        // 推斷對應的 UIView 類別名稱
        let viewModelName = String(describing: type(of: self))
        let viewName = viewModelName.replacingOccurrences(of: "ViewModel", with: "View")
        
        // 動態查找 UIView 類別
        guard let viewClass = NSClassFromString("\(namespace).\(viewName)") as? UIView.Type else {
            fatalError("Could not find a class named \(viewName) inheriting from UIView.")
        }
        
        // 初始化 UIView 實例
        let viewInstance = viewClass.init()
        
        // 如果該 UIView 支援 ViewModelConfigurable，則進行配置
        if let configurable = viewInstance as? (any ViewModelConfigurable) {
            configurable.configure(by: self)
        }
        
        // thread-safe 設定 associated object
        objc_setAssociatedObject(self, &AssociatedKeys, viewInstance, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        return viewInstance
    }
}

private extension Bundle {
    var namespace: String? {
        return infoDictionary?["CFBundleName"] as? String
    }
}

protocol ViewModelConfigurable {
    associatedtype ViewModel: ViewModelProtocol
    var viewModel: ViewModel? {get}
    func configure(model: ViewModel?)
}

extension ViewModelConfigurable {
    /// 可以透過 any 來執行 func configure(model: ViewModel)，會對其進行轉型
    func configure(by viewModel: Any) {
        guard let viewModel = viewModel as? ViewModel else {return}
        configure(model: viewModel)
    }
}
