//
//  Entry.swift
//  QuickKV
//
//  Created by jimmy on 2021/8/28.
//

import Foundation


struct CacheEntry: Codable {
    /// Cached object
    let data: Data
    /// Expiry date
    let expiry: CacheExpiry
    
    init(data: Data, expiry: CacheExpiry) {
        self.data = data
        self.expiry = expiry
    }
    
    enum CodingKeys: String, CodingKey {
        case data
        case expiry
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decode(Data.self, forKey: .data)
        let expiryDate = try values.decode(Date.self, forKey: .expiry)
        expiry = CacheExpiry.date(expiryDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(data, forKey: .data)
        try container.encode(expiry.date, forKey: .expiry)
    }
}
