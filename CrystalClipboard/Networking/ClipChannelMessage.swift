//
//  ClipChannelMessage.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/10/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Foundation

enum ClipChannelMessage {
    private static let decoder = ISO8601JSONDecoder()
    
    case clipCreated(clip: Clip)
    case clipDeleted(id: Int)
    
    init?(dictionary: [String: Any]) {
        if let deletedID = (dictionary["clip_deleted"] as? [String: Int])?["id"] {
            self = .clipDeleted(id: deletedID)
        } else if
            let clipDictionary = dictionary["clip_created"] as? [String: Any],
            // Roundabout, but the Decodable protocol only works with Data 😬
            let clipData = try? JSONSerialization.data(withJSONObject: clipDictionary),
            let clip = try? ClipChannelMessage.decoder.decode(Clip.self, from: clipData) {
            self = .clipCreated(clip: clip)
        } else {
            return nil
        }
    }
}
