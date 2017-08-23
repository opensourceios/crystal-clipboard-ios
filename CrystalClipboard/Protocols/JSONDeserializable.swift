//
//  JSONDeserializable.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/23/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

enum JSONDeserializationError: Error {
    case dataMissing
    case attributeMissing(name: String)
    case typeMissing
    case wrongType(expected: String, given: String)
}

protocol JSONDeserializable {
    static var dataType: String { get }
    static func from(JSON: [String: Any]) throws -> Self
}

extension JSONDeserializable {
    static func `in`(JSON: [String: Any]) throws -> Self {
        guard let data = JSON["data"] as? [String: Any] else { throw JSONDeserializationError.dataMissing }
        guard let type = data["type"] as? String else { throw JSONDeserializationError.typeMissing }
        guard type == Self.dataType else { throw JSONDeserializationError.wrongType(expected: Self.dataType, given: type) }
        
        return try Self.from(JSON: data)
    }
}
