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
        Clip(context: managedObjectContext, id: 1, text: "hi", createdAt: now)
        try! managedObjectContext.save()
        let fetchRequest = Clip.fetchRequest() as! NSFetchRequest<Clip>
        let clip = try! managedObjectContext.fetch(fetchRequest).first!
        XCTAssertEqual(clip.id, 1)
        XCTAssertEqual(clip.text, "hi")
        XCTAssertEqual(clip.createdAt, now)
    }
    
    func testUniqueId() {
        Clip(context: managedObjectContext, id: 1, text: "hi", createdAt: Date())
        Clip(context: managedObjectContext, id: 2, text: "yo", createdAt: Date())
        Clip(context: managedObjectContext, id: 1, text: "there can only be one", createdAt: Date())
        try! managedObjectContext.save()
        let fetchRequest = Clip.fetchRequest() as! NSFetchRequest<Clip>
        XCTAssertEqual(try! managedObjectContext.count(for: fetchRequest), 2)
    }
    
    func testDeserialization() {
        let jsonData = CrystalClipboardAuthenticatedAPI.createClip(text: "test").sampleData
        let json = try! JSONSerialization.jsonObject(with: jsonData) as! [String: Any]
        Clip(context: managedObjectContext, json: json)
        try! managedObjectContext.save()
        let fetchRequest = Clip.fetchRequest() as! NSFetchRequest<Clip>
        let clip = try! managedObjectContext.fetch(fetchRequest).first!
        XCTAssertEqual(clip.id, 5659)
        XCTAssertEqual(clip.text, "test")
        let createdAtString = JSON(json)["data"]["attributes"]["created-at"].stringValue
        let createdAt = DateParser.date(from: createdAtString)
        XCTAssertEqual(clip.createdAt, createdAt!)
    }
}
