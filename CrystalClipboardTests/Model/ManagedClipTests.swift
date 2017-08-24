//
//  ManagedClipTests.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/20/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
import CoreData
@testable import CrystalClipboard

class ManagedClipTests: CoreDataTestCase {
    func testInsert() {
        let now = Date()
        ManagedClip(from: Clip(id: 1, text: "hi", createdAt: now), context: managedObjectContext)
        try! managedObjectContext.save()
        let fetchRequest = ManagedClip.fetchRequest() as! NSFetchRequest<ManagedClip>
        let managedClip = try! managedObjectContext.fetch(fetchRequest).first!
        XCTAssertEqual(managedClip.id, 1)
        XCTAssertEqual(managedClip.text, "hi")
        XCTAssertEqual(managedClip.createdAt, now)
    }
    
    func testUniqueId() {
        ManagedClip(from: Clip(id: 1, text: "hi", createdAt: Date()), context: managedObjectContext)
        ManagedClip(from: Clip(id: 2, text: "yo", createdAt: Date()), context: managedObjectContext)
        ManagedClip(from: Clip(id: 1, text: "there can only be one", createdAt: Date()), context: managedObjectContext)
        try! managedObjectContext.save()
        let fetchRequest = ManagedClip.fetchRequest() as! NSFetchRequest<ManagedClip>
        XCTAssertEqual(try! managedObjectContext.count(for: fetchRequest), 2)
    }
}
