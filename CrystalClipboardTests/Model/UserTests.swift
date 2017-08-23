//
//  UserTests.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/23/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
@testable import CrystalClipboard

class UserTests: XCTestCase {
    func testJSONDeserialization() {
        let jsonData = CrystalClipboardAPI.me.sampleData
        let json = try! JSONSerialization.jsonObject(with: jsonData) as! [String: Any]
        print(json)
        let user = try! User.in(JSON: json)
        XCTAssertEqual(user.id, 666)
        XCTAssertEqual(user.email, "satan@hell.org")
    }
}
