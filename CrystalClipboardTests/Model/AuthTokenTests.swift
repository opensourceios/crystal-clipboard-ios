//
//  AuthTokenTests.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/23/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
@testable import CrystalClipboard

class AuthTokenTests: XCTestCase {
    func testJSONDeserialization() {
        let jsonData = CrystalClipboardAPI.signIn(email: "satan@hell.org", password: "password").sampleData
        let json = try! JSONSerialization.jsonObject(with: jsonData) as! [String: Any]
        let authToken = try! AuthToken.in(JSON: json)
        XCTAssertEqual(authToken.token, "Vy5KbYX116Y1him376FvAhkw")
    }
}
