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
    let json = ["detail": "is invalid", "source": ["pointer": "/data/attributes/email"]] as [String : Any]
    
    func testDeserialization() {
        let error = ResponseError(json: json)!
        XCTAssertEqual(error.detail, "is invalid")
        XCTAssertEqual(error.pointer, "/data/attributes/email")
    }
    
    func testBatchDeserialization() {
        let errorsJSON = ["errors": [json, json]] as [String: Any]
        let errors = ResponseError.deserializeErrors(json: errorsJSON)
        XCTAssertEqual(errors!.count, 2)
    }
    
    func testMessage() {
        let error = ResponseError(json: json)!
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
    
    func testCombinedErrorMessagesProperty() {
        CrystalClipboardAPI.testingProvider().request(.createUser(email: "satan@hell.org", password: "p")) { result in
            switch result {
            case let .success(response):
                XCTAssertEqual(response.combinedErrorMessages!, "Email has already been taken\nPassword is too short (minimum is 6 characters)")
            case .failure: XCTFail("Should be a response with unsuccessful status code and errors")
            }
        }
    }
    
    func testCombinedErrorMessagesPropertyIsNilOnSuccess() {
        CrystalClipboardAPI.testingProvider().request(.createUser(email: "satan+2@hell.org", password: "password")) { result in
            switch result {
            case let .success(response):
                XCTAssertNil(response.combinedErrorMessages)
            case .failure: XCTFail("Should be a successful response")
            }
        }
    }
}
