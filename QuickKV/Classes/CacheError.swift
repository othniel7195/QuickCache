//
//  CacheError.swift
//  Pods
//
//  Created by jimmy on 2021/8/28.
//

import Foundation

public enum CacheError: Error {
    case initializeFailed
    case notFound
    case decodingFailed
    case encodingFailed
    case transformerFailed
    case saveFailed
}
