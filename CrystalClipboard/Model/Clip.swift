//
//  Clip.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/20/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import CoreData

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
}
