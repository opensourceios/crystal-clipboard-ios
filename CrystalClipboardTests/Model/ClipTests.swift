//
//  ClipTests.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/20/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
import CoreData
import SwiftyJSON
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
    
    func testDeserialization() {
        let jsonData = CrystalClipboardAuthenticatedAPI.createClip(text: "test").sampleData
        let json = try! JSONSerialization.jsonObject(with: jsonData) as! [String: Any]
        managedObjectContext.performChangesAndWait {
            Clip.insert(into: self.managedObjectContext, json: json)
        }
        let fetchRequest = NSFetchRequest<Clip>(entityName: "Clip")
        let clip = try! managedObjectContext.fetch(fetchRequest).first!
        XCTAssertEqual(clip.id, 5659)
        XCTAssertEqual(clip.text, "test")
        let createdAtString = JSON(json)["data"]["attributes"]["created-at"].stringValue
        let createdAt = DateParser.date(from: createdAtString)
        XCTAssertEqual(clip.createdAt, createdAt!)
    }
}
