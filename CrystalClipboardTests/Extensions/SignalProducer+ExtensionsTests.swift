//
//  SignalProducer+ExtensionsTests.swift
//  CrystalClipboardTests
//
//  Created by Justin Mazzocchi on 9/2/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
import ReactiveSwift
@testable import CrystalClipboard

class SignalProducer_ExtensionsTests: ProviderTestCase {    
    func testDecode() {
        let user = try! testData.createUser(email: generateEmail(), password: generateString())
        
        var usersDecoded = 0
        provider.reactive.request(.me).decode(to: User.self).start { event in
            switch event {
            case let .value(decodedUser):
                XCTAssertEqual(decodedUser.email, user.email)
                usersDecoded += 1
            case .completed: XCTAssertEqual(usersDecoded, 1)
            case .interrupted: XCTFail("User decoding was interrupted")
            case let .failed(error): XCTFail("Failed to decode user: \(error)")
            }
        }
    }
    
    func testDecodeErrors() {
        provider.reactive.request(.signIn(email: generateEmail(), password: generateString())).decode(to: User.self).start { event in
            switch event {
            case let .failed(error):
                guard case let .with(response: _, remoteErrors: decodedErrors) = error else { XCTFail("Should have decoded errors"); break }
                XCTAssertEqual(decodedErrors.count, 1)
                XCTAssertEqual(decodedErrors.first!.message, "The email or password provided was incorrect")
            default: XCTFail("Should error")
            }
        }
    }
}
