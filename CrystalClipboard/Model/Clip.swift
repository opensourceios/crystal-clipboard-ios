//
//  Clip.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/24/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Foundation

struct Clip {
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
    
    static func from(JSON: [String: Any], included: [[String: Any]]?) throws -> Clip {
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
