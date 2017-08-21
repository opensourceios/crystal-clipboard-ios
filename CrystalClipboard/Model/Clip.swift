//
//  Clip.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/20/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import CoreData
import SwiftyJSON

class Clip: NSManagedObject {
    @NSManaged fileprivate(set) var id: Int
    @NSManaged fileprivate(set) var text: String
    @NSManaged fileprivate(set) var createdAt: Date
    
    @discardableResult
    static func insert(into context: NSManagedObjectContext, id: Int, text: String, createdAt: Date) -> Clip {
        let clip: Clip = context.insertObject()
        clip.id = id
        clip.text = text
        clip.createdAt = createdAt
        return clip
    }
    
    @discardableResult
    static func insert(into context: NSManagedObjectContext, json: [String: Any]) -> Clip? {
        let swiftyJSON = JSON(json)
        guard
            let idString = swiftyJSON["data"]["id"].string,
            let id = Int(idString),
            let text = swiftyJSON["data"]["attributes"]["text"].string,
            let dateString = swiftyJSON["data"]["attributes"]["created-at"].string,
            let date = DateParser.date(from: dateString) else {
                return nil
        }
        return insert(into: context, id: id, text: text, createdAt: date)
    }
}
