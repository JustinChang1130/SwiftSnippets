//
//  TableViewModel.swift
//  DJCoreApp
//
//  Created by 張啟裕 on 2023/12/28.
//  Copyright © 2023 SysJust. All rights reserved.
//

import UIKit

struct SectionViewModel {
    
    @Observing private(set) var isExpand = true
    @ExpandableRows var rowViewModels = [ViewModelProtocol]()
    
    init(isExpand: Bool = true, rowViewModels: [ViewModelProtocol] = [ViewModelProtocol]()) {
        self.isExpand = isExpand
        self.rowViewModels = rowViewModels
        _rowViewModels.switchExpand(to: isExpand)
    }
    
    @discardableResult
    mutating func switchExpand(to isExpand: Bool? = nil) -> Bool {
        _rowViewModels.switchExpand(to: isExpand)
        self.isExpand = $rowViewModels.isExpand
        return self.isExpand
    }
}

extension Array where Element == SectionViewModel {
    subscript<T: RawRepresentable>(_ enumValue: T) -> SectionViewModel where T.RawValue == Int {
        get {
            return self[enumValue.rawValue]
        }
        set {
            self[enumValue.rawValue] = newValue
        }
    }
}

extension SectionViewModel {
    var allRowModels: [ViewModelProtocol] {
        self.$rowViewModels.value
    }
}

@propertyWrapper
struct ExpandableRows {
    
    var value: [ViewModelProtocol]
    private(set) var isExpand = false
    private(set) var expandIndex = 1
    
    init(wrappedValue: [ViewModelProtocol]) {
        self.value = wrappedValue
    }
    
    var projectedValue: ExpandableRows {self}
    
    var wrappedValue: [ViewModelProtocol] {
        get {
            if isExpand {
                return value
            } else {
                return Array(value.prefix(expandIndex))
            }
        }
        set { value = newValue }
    }
    
    mutating func switchExpand(to isExpand: Bool? = nil) {
        if let isExpand = isExpand {
            self.isExpand = isExpand
        } else {
            self.isExpand.toggle()
        }
    }
    
    mutating func setExpandIndex(index: Int) {
        self.expandIndex = index
    }
    
    subscript<T: RawRepresentable>(_ enumValue: T) -> ViewModelProtocol where T.RawValue == Int {
        get {
            return value[enumValue.rawValue]
        }
        set {
            value[enumValue.rawValue] = newValue
        }
    }
}

protocol RowPressible {
    var rowPressed: (()->Void)? { get set }
}
