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
    static let jsonData = CrystalClipboardAPI.signIn(email: "satan@hell.org", password: "password").sampleData
    let user = try! ISO8601JSONDecoder().decode(User.self, from: UserTests.jsonData)
    
    func testDecoding() {
        XCTAssertEqual(user.id, 666)
        XCTAssertEqual(user.email, "satan@hell.org")
        XCTAssertEqual(user.authToken!.token, "Vy5KbYX116Y1him376FvAhkw")
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
        XCTAssertEqual(keychain["auth-token"], "Vy5KbYX116Y1him376FvAhkw")
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
