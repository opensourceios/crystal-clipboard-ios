//
//  SignalProducer+ExtensionsTests.swift
//  CrystalClipboardTests
//
//  Created by Justin Mazzocchi on 9/2/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
import Moya
import ReactiveSwift
@testable import CrystalClipboard

class SignalProducer_ExtensionsTests: XCTestCase {
    let provider =  APIProvider.testingProvider()
    
    func testDecode() {
        var usersDecoded = 0
        provider.reactive.request(.me).decode(to: User.self).start { event in
            switch event {
            case let .value(user):
                XCTAssertEqual(user.id, 666)
                XCTAssertEqual(user.email, "satan@hell.org")
                usersDecoded += 1
            case .completed: XCTAssertEqual(usersDecoded, 1)
            case .interrupted: XCTFail("User decoding was interrupted")
            case let .failed(error): XCTFail("Failed to decode user: \(error)")
            }
        }
    }
    
    func testDecodeErrors() {
        var errorsDecoded = 0
        provider.reactive.request(.signIn(email: "satanhell.org", password: "password")).decode(to: User.self).start { event in
            switch event {
            case let .failed(error):
                guard case let .with(decodedErrors) = error else { XCTFail("Should have decoded errors"); break }
                XCTAssertEqual(decodedErrors.count, 1)
                XCTAssertEqual(decodedErrors.first!.message!, "The email or password provided was incorrect")
            default: XCTFail("Should error")
            }
        }
    }
}
