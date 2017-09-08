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
        let user = User(id: generateNumber(), email: generateEmail())
        let clip = Clip(id: generateNumber(), text: generateString(), createdAt: Date(), user: user)
        ManagedClip(from: clip, context: context)
        try! context.save()
        let fetchRequest = ManagedClip.fetchRequest() as! NSFetchRequest<ManagedClip>
        let managedClip = try! context.fetch(fetchRequest).first!
        XCTAssertEqual(managedClip.id, clip.id)
        XCTAssertEqual(managedClip.text, clip.text)
        XCTAssertEqual(managedClip.createdAt, clip.createdAt)
    }
}
