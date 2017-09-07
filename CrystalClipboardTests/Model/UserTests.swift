//
//  UserTests.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/23/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
import KeychainAccess
@testable import CrystalClipboard

class UserTests: XCTestCase {
    var user: User!
    
    override func setUp() {
        user = User(id: 666, email: "satan@hell.org", authToken: User.AuthToken(token: "lol"))
    }
    
    override func tearDown() {
        user = nil
    }
    
    func testDecoding() {
        let jsonData = "{\"id\":666,\"email\":\"satan@hell.org\",\"auth_token\":{\"token\":\"lol\"}}".data(using: .utf8)!
        let decodedUser = try! JSONDecoder().decode(User.self, from: jsonData)
        XCTAssertEqual(decodedUser.id, 666)
        XCTAssertEqual(decodedUser.email, "satan@hell.org")
        XCTAssertEqual(decodedUser.authToken!.token, "lol")
    }
    
    func testUserDefaultsPersistence() {
        User.current = user
        XCTAssertEqual(User.current!.id, user.id)
        XCTAssertEqual(User.current!.email, user.email)
        User.current = nil
        XCTAssertNil(User.current)
    }
    
    func testAuthTokenKeychainPersistence() {
        let keychain = Keychain(service: Constants.keychainService)
        User.current = nil
        User.current = user
        XCTAssertEqual(keychain["auth-token"], "lol")
        User.current = nil
        XCTAssertNil(keychain["auth-token"])
    }

    func testNotifiesSignIn() {
        User.current = nil
        expectation(forNotification: Notification.Name.userSignedIn, object: nil, handler: nil)
        User.current = user
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testNotifiesSignOut() {
        User.current = user
        expectation(forNotification: Notification.Name.userSignedOut, object: nil, handler: nil)
        User.current = nil
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testNotifiesUserUpdated() {
        User.current = user
        expectation(forNotification: Notification.Name.userUpdated, object: nil, handler: nil)
        User.current = User(id: 666, email: "satan+newemail@gmail.com")
        waitForExpectations(timeout: 1, handler: nil)
    }
}
