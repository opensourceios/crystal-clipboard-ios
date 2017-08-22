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
}
