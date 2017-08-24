//
//  ResponseErrorTests.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/22/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
@testable import CrystalClipboard

class ResponseErrorTests: XCTestCase {
    func testMessage() {
        let error = ResponseError(detail: "is invalid", pointer: "/data/attributes/email")
        XCTAssertEqual(error.message, "Email is invalid")
    }
    
    func testResponseErrorsProperty() {
        CrystalClipboardAPI.testingProvider().request(.createUser(email: "satan@hell.org", password: "p")) { result in
            switch result {
            case let .success(response):
                XCTAssertEqual(response.errors.count, 2)
                XCTAssertEqual(response.errors.first!.message, "Email has already been taken")
                XCTAssertEqual(response.errors.last!.message, "Password is too short (minimum is 6 characters)")
            case .failure: XCTFail("Should be a response with unsuccessful status code and errors")
            }
        }
    }
}
