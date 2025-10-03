//
//  UserDefault.swift
//
//  Created by Justin on 2023/12/28.
//

import Foundation

extension UserDefaults {
    
    static var prefix: String { Bundle.main.bundleIdentifier ?? "" + "." }
    
    // MARK: - Normal Key
    
    struct Key<Value> {
        let name: String
        init(_ name: String) {
            self.name = name
        }
    }
    
    static subscript<V: Codable>(key: UserDefaults.Key<V>) -> V? {
        get {
            return standard[key]
        }
        set {
            standard[key] = newValue
            standard.synchronize()
        }
    }
    
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
    
    // MARK: - CacheKey
    
    struct CacheKey<Value: Codable>: Hashable {
        let name: String
        let cacheDuration: TimeInterval
        
        init(_ name: String, cacheDuration: TimeInterval = 60 * 60 * 24) {
            self.name = name
            self.cacheDuration = cacheDuration
        }
    }
    
    static subscript<V: Codable>(cache Key: UserDefaults.CacheKey<V>) -> V? {
        get {
            return standard[Key]
        }
        set {
            standard[Key] = newValue
            standard.synchronize()
        }
    }
    
    subscript<T: Codable>(cacheKey: CacheKey<T>) -> T? {
        get {
            guard let data = data(forKey: cacheKey.name),
                  let cache = try? JSONDecoder().decode(TimedCache<T>.self, from: data)
            else {
                return nil
            }
            
            let now = Date().timeIntervalSince1970
            if now - cache.timestamp > cacheKey.cacheDuration {
                removeObject(forKey: cacheKey.name)
                return nil
            }
            
            return cache.value
        }
        set {
            if let value = newValue {
                let cache = TimedCache(value: value, timestamp: Date().timeIntervalSince1970)
                if let encoded = try? JSONEncoder().encode(cache) {
                    set(encoded, forKey: cacheKey.name)
                }
            } else {
                removeObject(forKey: cacheKey.name)
            }
        }
    }
}

extension UserDefaults.Key {
    
    typealias Key = UserDefaults.Key
    
    static var prefix: String { UserDefaults.prefix }
    
    struct App {
        static var firstLoginDate: Key<Date> { .init("\(prefix).\(Self.self).firstLoginDate") }
    }
}

extension UserDefaults.CacheKey {
    
    typealias Key = UserDefaults.CacheKey
    
    static var prefix: String { UserDefaults.prefix }
    
    static var branchList: Key<[String]> { .init("\(prefix)branchList", cacheDuration: 60 * 60 * 12) }
}
