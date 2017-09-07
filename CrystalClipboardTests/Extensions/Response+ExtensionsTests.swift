//
//  Response+ExtensionsTests.swift
//  CrystalClipboardTests
//
//  Created by Justin Mazzocchi on 9/2/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
@testable import CrystalClipboard

class Response_ExtensionsTests: ProviderTestCase {
    func testDecode() {
        try! testData.createUser(email: "satan@hell.org", password: "password")
        
        provider.request(.me) { result in
            switch result {
            case let .success(response):
                let user = try! response.decode(to: User.self)
                XCTAssertEqual(user.email, "satan@hell.org")
            case .failure: XCTFail("Should be a successful response")
            }
        }
    }
}
