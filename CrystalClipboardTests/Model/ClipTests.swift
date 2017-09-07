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
        let jsonData = "{\"id\":999,\"text\":\"lol\",\"created_at\":\"2017-09-07T11:47:27.713-04:00\",\"user\":{\"id\":666,\"email\":\"satan@hell.org\"}}".data(using: .utf8)!
        let clip = try! ISO8601JSONDecoder().decode(Clip.self, from: jsonData)
        XCTAssertEqual(clip.id, 999)
        XCTAssertEqual(clip.text, "lol")
    }
}
