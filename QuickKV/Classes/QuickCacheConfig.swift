//
//  QuickCacheConfig.swift
//  QuickKV
//
//  Created by jimmy on 2021/8/29.
//

import Foundation

public struct QuickCacheConfig {
    public let name: String
    public let expiry: CacheExpiry
    
    public init(name: String, expiry: CacheExpiry = .nerver) {
        self.name = name
        self.expiry = expiry
    }
}
