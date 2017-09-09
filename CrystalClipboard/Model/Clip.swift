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
        case id, text, userID = "user_id", createdAt = "created_at"
    }
    
    let id: Int
    let text: String
    let userID: Int
    let createdAt: Date
}
