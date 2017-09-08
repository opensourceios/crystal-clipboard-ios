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
        let user = try! testRemoteData.createUser(email: generateString(), password: generateString())
        
        provider.request(.me) { result in
            switch result {
            case let .success(response):
                let decodedUser = try! response.decode(to: User.self)
                XCTAssertEqual(decodedUser.email, user.email)
            case .failure: XCTFail("Should be a successful response")
            }
        }
    }
}
