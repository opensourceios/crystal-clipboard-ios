//
//  APIResponseTests.swift
//  CrystalClipboardTests
//
//  Created by Justin Mazzocchi on 9/2/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
@testable import CrystalClipboard

class APIResponseTests: XCTestCase {
    func testErrors() {
        let jsonData = CrystalClipboardAPI.createUser(email: "satan@hell.org", password: "p").sampleData
        let errors = try! APIResponseDecoder().decode(APIResponse<User>.self, from: jsonData).errors!
        XCTAssertEqual(errors.count, 2)
        let error = errors.first!
        XCTAssertEqual(error.source!.pointer, "/data/attributes/email")
        XCTAssertEqual(error.detail, "has already been taken")
        XCTAssertEqual(error.message, "Email has already been taken")
    }
}
