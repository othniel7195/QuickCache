//
//  QuickCache.swift
//  QuickKV
//
//  Created by zf on 2021/8/29.
//

import Foundation
import MMKV

public final class QuickCache<T> {
    
    
    
    let config: QuickCacheConfig
    let transformer: Transformer<T>
    let mmkv: MMKV
    
    init(mmkv: MMKV, config: QuickCacheConfig, transformer: Transformer<T>) {
        self.mmkv = mmkv
        self.config = config
        self.transformer = transformer
    }
    
    public convenience init(config: QuickCacheConfig, transformer: Transformer<T>) throws {
        if let mmkv = MMKV(mmapID: config.name, cryptKey: kQuickCache) {
            self.init(mmkv: mmkv, config: config, transformer: transformer)
        } else {
            throw CacheError.initializeFailed
        }
    }
}

private let kQuickCache: Data? = "QuickCache".data(using: .utf8)


// MARK: Basic operation
public extension QuickCache {
    
    func setObject(_ object: T, forKey key: String, expiry: CacheExpiry? = nil) throws {
        let expiry = expiry ?? config.expiry
        let data = try transformer.toData(object)
        let entry = CacheEntry(data: data, expiry: expiry)
        try mmkvSet(entry: entry, key: key, mmkv: mmkv)
    }
    
    func getObject(forKey key: String) throws -> T {
        let entry = try mmkvGet(forKey: key, mmkv: mmkv)
        return try transformer.fromData(entry.data)
    }
    
    func getObjectWithExpiry(forKey key: String) throws -> (T, Bool) {
        let entry = try mmkvGet(forKey: key, mmkv: mmkv)
        let t = try transformer.fromData(entry.data)
        return (t, entry.expiry.isExpired)
    }
    
    func existsObject(forKey key: String) -> Bool {
        return mmkv.contains(key: key)
    }
    
    func forEachKeys(_ key: @escaping (String) -> Void) {
        return mmkv.enumerateKeys { k, _ in
            key(k)
        }
    }
    
    func removeObject(forKey key: String) {
        mmkv.removeValue(forKey: key)
    }
    
    func removeObjectIfExpired(forKey key: String) {
        if let entry = try? mmkvGet(forKey: key, mmkv: mmkv), entry.expiry.isExpired {
            removeObject(forKey: key)
        }
    }
    
    func removeObjects(forKeys keys: [String]) {
        mmkv.removeValues(forKeys: keys)
    }
    
    func removeAll() {
        mmkv.clearAll()
    }
    
    func removeExpiredObjects() {
        forEachKeys { k in
            self.removeObjectIfExpired(forKey: k)
        }
    }
    
    func isExpiredObject(forKey key: String) -> Bool {
        do {
            let entry = try mmkvGet(forKey: key, mmkv: mmkv)
            return entry.expiry.isExpired
        } catch {
            // not found is true
            return true
        }
    }
    
    var totalSize: Int {
        return mmkv.totalSize()
    }
    
    var count: Int {
        return mmkv.count()
    }
}


// MARK: Transform
public extension QuickCache {
    
    func transform<U>(transformer: Transformer<U>) -> QuickCache<U> {
        return QuickCache<U>(mmkv: mmkv, config: config, transformer: transformer)
    }
    
    func transformData() -> QuickCache<Data> {
        let storage = transform(transformer: TransformerFactory.forData())
        return storage
    }
    
    func transformCodable<U: Codable>(ofType: U.Type) -> QuickCache<U> {
        let storage = transform(transformer: TransformerFactory.forCodable(ofType: U.self))
        return storage
    }
}
