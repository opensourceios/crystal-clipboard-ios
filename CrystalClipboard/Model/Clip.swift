//
//  Clip.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/24/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Foundation

struct Clip: ClipType, Codable {
    enum CodingKeys: String, CodingKey {
        case id, text, createdAt = "created_at"
    }
    
    let id: Int
    let text: String
    let createdAt: Date
    
    init(id: Int, text: String, createdAt: Date) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
    }
}
