//
//  JSONDeserializable.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/23/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

enum JSONDeserializationError: Error {
    case invalidStructure
    case invalidType
    case invalidAttributes
}

protocol JSONDeserializable {
    static var JSONType: String { get }
    static func from(JSON: [String: Any], included: [[String: Any]]?) throws -> Self
}

extension JSONDeserializable {
    static func `in`(JSON: [String: Any]) throws -> Self {
        guard let data = JSON["data"] as? [String: Any] else { throw JSONDeserializationError.invalidStructure }
        guard let type = data["type"] as? String, type == Self.JSONType else { throw JSONDeserializationError.invalidType }
        
        return try Self.from(JSON: data, included: JSON["included"] as? [[String: Any]])
    }
    
    static func manyIn(JSON: [String: Any]) -> [Self] {
        guard let data = JSON["data"] as? [[String: Any]] else { return [] }
        return data.filter { $0["type"] as? String == Self.JSONType }.flatMap { try? Self.from(JSON: $0, included: JSON["included"] as? [[String: Any]]) }
    }
}
