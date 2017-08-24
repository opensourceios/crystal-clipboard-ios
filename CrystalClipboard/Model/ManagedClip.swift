//
//  ManagedClip.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/20/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import CoreData
import SwiftyJSON

class ManagedClip: NSManagedObject {
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
}
