//
//  ClipTests.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/20/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
import CoreData
@testable import CrystalClipboard

class ClipTests: CoreDataTestCase {
    func testInsert() {
        let now = Date()
        managedObjectContext.performChangesAndWait {
            Clip.insert(into: self.managedObjectContext, id: 1, text: "hi", createdAt: now)
        }
        let fetchRequest = NSFetchRequest<Clip>(entityName: "Clip")
        let clip = try! managedObjectContext.fetch(fetchRequest).first!
        XCTAssertEqual(clip.id, 1)
        XCTAssertEqual(clip.text, "hi")
        XCTAssertEqual(clip.createdAt, now)
    }
    
    func testUniqueId() {
        managedObjectContext.performChangesAndWait {
            Clip.insert(into: self.managedObjectContext, id: 1, text: "hi", createdAt: Date())
            Clip.insert(into: self.managedObjectContext, id: 2, text: "yo", createdAt: Date())
            Clip.insert(into: self.managedObjectContext, id: 1, text: "there can only be one", createdAt: Date())
        }
        let fetchRequest = NSFetchRequest<Clip>(entityName: "Clip")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Clip.text), ascending: true)]
        XCTAssertEqual(try! managedObjectContext.count(for: fetchRequest), 2)
        let clip = try! managedObjectContext.fetch(fetchRequest).first!
        XCTAssertEqual(clip.text, "hi")
    }
}
