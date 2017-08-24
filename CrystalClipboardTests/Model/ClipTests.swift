//
//  ClipTests.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/24/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
@testable import CrystalClipboard

class ClipTests: XCTestCase {
    func testJSONDeserialization() {
        let jsonData = CrystalClipboardAPI.createClip(text: "lol").sampleData
        let json = try! JSONSerialization.jsonObject(with: jsonData) as! [String: Any]
        let clip = try! Clip.in(JSON: json)
        XCTAssertEqual(clip.id, 5659)
        XCTAssertEqual(clip.text, "lol")
        XCTAssertEqual(clip.createdAt, DateParser.date(from: "2017-08-20T16:33:52.100Z")!)
    }
}
