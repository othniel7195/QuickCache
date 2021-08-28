//
//  CacheExpiry.swift
//  QuickKV
//
//  Created by jimmy on 2021/8/28.
//

import Foundation

public enum CacheExpiry {
    case nerver
    case seconds(TimeInterval)
    case date(Date)
    
    public var date: Date {
        switch self {
        case .nerver:
            return Date(timeIntervalSince1970: 60 * 60 * 24 * 365 * 68)
        case .seconds(let seconds):
            return Date().addingTimeInterval(seconds)
        case .date(let date):
            return date
        }
    }
    
    public var isExpired: Bool {
        return date.inThePast
    }
}

extension Date {
    var inThePast: Bool {
        return timeIntervalSinceNow < 0
    }
}
