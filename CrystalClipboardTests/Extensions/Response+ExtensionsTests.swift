//
//  Response+ExtensionsTests.swift
//  CrystalClipboardTests
//
//  Created by Justin Mazzocchi on 9/2/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
@testable import CrystalClipboard

class Response_ExtensionsTests: XCTestCase {
    func testDecode() {
        APIProvider.testingProvider().request(.me) { result in
            switch result {
            case let .success(response):
                let user = try! response.decode(to: User.self)
                XCTAssertEqual(user.id, 666)
            case .failure: XCTFail("Should be a successful response")
            }
        }
    }
    
    func testDecodeIncluded() {
        APIProvider.testingProvider().request(.signIn(email: "satan@hell.org", password: "password")) { result in
            switch result {
            case let .success(response):
                let (user, tokens) = try! response.decode(to: User.self, included: AuthToken.self)
                XCTAssertEqual(user.id, 666)
                let authToken = tokens.first!
                XCTAssertEqual(authToken.token, "Vy5KbYX116Y1him376FvAhkw")
            case .failure: XCTFail("Should be a successful response")
            }
        }
    }
}
