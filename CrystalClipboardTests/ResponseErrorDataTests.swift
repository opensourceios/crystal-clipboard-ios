//
//  ResponseErrorDataTests.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/22/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
@testable import CrystalClipboard

class ResponseErrorDataTests: XCTestCase {
    func testMessage() {
        let error = ResponseErrorData(detail: "is invalid", pointer: "/data/attributes/email")
        XCTAssertEqual(error.message, "Email is invalid")
    }
    
    func testResponseErrorsProperty() {
        CrystalClipboardAPI.testingProvider().request(.createUser(email: "satan@hell.org", password: "p")) { result in
            switch result {
            case let .success(response):
                XCTAssertEqual(response.errorData.count, 2)
                XCTAssertEqual(response.errorData.first!.message, "Email has already been taken")
                XCTAssertEqual(response.errorData.last!.message, "Password is too short (minimum is 6 characters)")
            case .failure: XCTFail("Should be a response with unsuccessful status code and errors")
            }
        }
    }
}
