//
//  Clip.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/24/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Foundation

struct Clip: ClipType {
    let id: Int
    let text: String
    let createdAt: Date
    
    init(id: Int, text: String, createdAt: Date) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
    }
}

extension Clip: JSONDeserializable {
    static let JSONType = "clips"
    
    static func from(JSON: [String : Any]) throws -> Clip {
        guard
            let idString = JSON["id"] as? String,
            let id = Int(idString),
            let attributes = JSON["attributes"] as? [String: Any],
            let text = attributes["text"] as? String,
            let createdAtString = attributes["created-at"] as? String,
            let createdAt = DateParser.date(from: createdAtString)
            else { throw JSONDeserializationError.invalidAttributes }
        
        return Clip(id: id, text: text, createdAt: createdAt)
    }
}

extension Clip: Decodable {
    private enum DataKeys: String, CodingKey {
        case id
        case attributes
        enum AttributeKeys: String, CodingKey {
            case text
            case createdAt = "created-at"
        }
    }
    
    init(from decoder: Decoder) throws {
        let data = try decoder.container(keyedBy: DataKeys.self)
        let attributes = try data.nestedContainer(keyedBy: DataKeys.AttributeKeys.self, forKey: .attributes)
        let idString = try data.decode(String.self, forKey: .id)
        guard let id = Int(idString) else { throw NSError() }
        self.id = id
        text = try attributes.decode(String.self, forKey: .text)
        createdAt = try attributes.decode(Date.self, forKey: .createdAt)
    }
}
