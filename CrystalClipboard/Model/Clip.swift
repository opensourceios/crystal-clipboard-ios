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
    convenience init(context: NSManagedObjectContext, id: Int, text: String, createdAt: Date) {
        self.init(context: context)
        self.id = id
        self.text = text
        self.createdAt = createdAt
    }
    
    @discardableResult
    convenience init?(context: NSManagedObjectContext, json: [String: Any]) {
        let swiftyJSON = JSON(json)
        guard
            let idString = swiftyJSON["data"]["id"].string,
            let id = Int(idString),
            let text = swiftyJSON["data"]["attributes"]["text"].string,
            let dateString = swiftyJSON["data"]["attributes"]["created-at"].string,
            let date = DateParser.date(from: dateString) else {
                return nil
        }
        self.init(context: context, id: id, text: text, createdAt: date)
    }
}
