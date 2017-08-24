//
//  ManagedClip.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/20/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import CoreData

class ManagedClip: NSManagedObject {
    @NSManaged fileprivate(set) var id: Int
    @NSManaged fileprivate(set) var text: String
    @NSManaged fileprivate(set) var createdAt: Date
    
    @discardableResult
    convenience init(from clip: Clip, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = clip.id
        self.text = clip.text
        self.createdAt = clip.createdAt
    }
}
