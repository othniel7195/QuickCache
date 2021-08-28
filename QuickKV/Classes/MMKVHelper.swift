//
//  MMKVHelper.swift
//  QuickKV
//
//  Created by jimmy on 2021/8/29.
//

import Foundation
import MMKV

func mmkvSet(entry: CacheEntry, key: String, mmkv: MMKV) throws {
    let entryData = try TransformerFactory.forCodable(ofType: CacheEntry.self).toData(entry)
    if !mmkv.set(entryData, forKey: key) {
        throw CacheError.saveFailed
    }
}

func mmkvGet(forKey key: String, mmkv: MMKV) throws -> CacheEntry {
    if let data = mmkv.object(of: NSData.self, forKey: key) as? Data {
        return try TransformerFactory.forCodable(ofType: CacheEntry.self).fromData(data)
    } else {
        throw CacheError.notFound
    }
}
