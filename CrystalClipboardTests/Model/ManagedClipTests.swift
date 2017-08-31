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
        let context = persistentContainer.viewContext
        let now = Date()
        ManagedClip(from: Clip(id: 1, text: "hi", createdAt: now), context: context)
        try! context.save()
        let fetchRequest = ManagedClip.fetchRequest() as! NSFetchRequest<ManagedClip>
        let managedClip = try! context.fetch(fetchRequest).first!
        XCTAssertEqual(managedClip.id, 1)
        XCTAssertEqual(managedClip.text, "hi")
        XCTAssertEqual(managedClip.createdAt, now)
    }
}
