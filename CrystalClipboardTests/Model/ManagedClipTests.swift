//
//  ManagedClipTests.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/20/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
import CoreData
import SwiftyJSON
@testable import CrystalClipboard

class ManagedClipTests: CoreDataTestCase {
    func testInsert() {
        let now = Date()
        ManagedClip(context: managedObjectContext, id: 1, text: "hi", createdAt: now)
        try! managedObjectContext.save()
        let fetchRequest = ManagedClip.fetchRequest() as! NSFetchRequest<ManagedClip>
        let managedClip = try! managedObjectContext.fetch(fetchRequest).first!
        XCTAssertEqual(managedClip.id, 1)
        XCTAssertEqual(managedClip.text, "hi")
        XCTAssertEqual(managedClip.createdAt, now)
    }
    
    func testUniqueId() {
        ManagedClip(context: managedObjectContext, id: 1, text: "hi", createdAt: Date())
        ManagedClip(context: managedObjectContext, id: 2, text: "yo", createdAt: Date())
        ManagedClip(context: managedObjectContext, id: 1, text: "there can only be one", createdAt: Date())
        try! managedObjectContext.save()
        let fetchRequest = ManagedClip.fetchRequest() as! NSFetchRequest<ManagedClip>
        XCTAssertEqual(try! managedObjectContext.count(for: fetchRequest), 2)
    }
}
