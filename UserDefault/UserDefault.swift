//
//  UserDefault.swift
//
//  Created by Justin on 2023/12/28.
//

import Foundation

struct UserDefault {
    
    static subscript<V: Codable>(key: UserDefaults.Key<V>) -> V? {
        get {
            return UserDefaults.standard[key]
        }
        set {
            UserDefaults.standard[key] = newValue
            UserDefaults.standard.synchronize()
        }
    }
}

extension UserDefaults {
    
    struct Key<Value> {
        let name: String
        init(_ name: String) {
            self.name = name
        }
    }
    
    private var prefix: String {Bundle.main.bundleIdentifier ?? "" + "."}
    
    subscript<V: Codable>(key: Key<V>) -> V? {
        get {
            guard let data = self.data(forKey: prefix + key.name) else {
                return nil
            }
            return try? JSONDecoder().decode(V.self, from: data)
        }
        set {
            guard let value = newValue, let data = try? JSONEncoder().encode(value) else {
                self.set(nil, forKey: key.name)
                return
            }
            self.set(data, forKey: prefix + key.name)
        }
    }
}

extension UserDefaults.Key {
    
    typealias Key = UserDefaults.Key
        
    static var lastUpdateDate: Key<Date> {Key<Date>("lastUpdateDate")}
    
    // TODO: add other key
}
