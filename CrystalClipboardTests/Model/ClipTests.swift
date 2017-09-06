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
    func testDecoding() {
        let jsonData = CrystalClipboardAPI.createClip(text: "lol").sampleData
        let clip = try! APIResponseDecoder().decode(Clip.self, from: jsonData)
        XCTAssertEqual(clip.text, "lol")
    }
}
