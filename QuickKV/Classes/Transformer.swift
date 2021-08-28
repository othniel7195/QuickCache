//
//  Transformer.swift
//  QuickKV
//
//  Created by jimmy on 2021/8/29.
//

import Foundation

public class Transformer<T> {
    let toData: (T) throws -> Data
    let fromData: (Data) throws -> T
    
    public init(toData: @escaping (T) throws -> Data, fromData: @escaping (Data) throws -> T) {
        self.toData = toData
        self.fromData = fromData
    }
}


public class TransformerFactory {
    
    public static func forData() -> Transformer<Data> {
        let toData: (Data) throws -> Data = { $0 }
        let fromData: (Data) throws -> Data = { $0 }
        
        return Transformer<Data>(toData: toData, fromData: fromData)
    }
    
    public static func forCodable<U: Codable>(ofType: U.Type) -> Transformer<U> {
        let toData: (U) throws -> Data = { object in
            let wrapper = TypeWrapper<U>(object: object)
            let encoder = JSONEncoder()
            
            return try encoder.encode(wrapper)
        }
        
        let fromData: (Data) throws -> U = { data in
            let decoder = JSONDecoder()
            
            return try decoder.decode(TypeWrapper<U>.self, from: data).object
        }
        
        return Transformer<U>(toData: toData, fromData: fromData)
    }
}


///wrap codable object
struct TypeWrapper<T: Codable>: Codable {
    let object: T
    
    init(object: T) {
        self.object = object
    }
    
    enum CodingKeys: String, CodingKey {
        case object
    }
}


public typealias JSONDict = [String: Any]

public struct JSONDictWrapper: Codable {
    public let jsonDict: JSONDict
    
    public enum CodingKeys: String, CodingKey {
        case jsonDict
    }
    
    public init(jsonDict: JSONDict) {
        self.jsonDict = jsonDict
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.decode(Data.self, forKey: .jsonDict)
        let object = try JSONSerialization.jsonObject(with: data, options: [])
        
        guard let jsonDict = object as? JSONDict else {
            throw CacheError.decodingFailed
        }
        
        self.jsonDict = jsonDict
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let data = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
        
        try container.encode(data, forKey: CodingKeys.jsonDict)
    }
}


public typealias JSONArray = [JSONDict]

public struct JSONArrayWrapper: Codable {
    public let jsonArray: JSONArray
    
    public enum CodingKeys: String, CodingKey {
        case jsonArray
    }
    
    public init(jsonArray: JSONArray) {
        self.jsonArray = jsonArray
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.decode(Data.self, forKey: .jsonArray)
        let object = try JSONSerialization.jsonObject(with: data, options: [])
        
        guard let jsonArray = object as? JSONArray else {
            throw CacheError.decodingFailed
        }
        
        self.jsonArray = jsonArray
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let data = try JSONSerialization.data(withJSONObject: jsonArray, options: [])
        
        try container.encode(data, forKey: .jsonArray)
    }
}
