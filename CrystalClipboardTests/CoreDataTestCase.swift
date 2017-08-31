//
//  CoreDataTestCase.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/20/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
import CoreData

class CoreDataTestCase: XCTestCase {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CrystalClipboard")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("Could not load store: \(error)")
            }
        }
        return container
    }()
}
