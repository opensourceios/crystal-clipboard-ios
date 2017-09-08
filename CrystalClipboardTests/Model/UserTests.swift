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
        user = User(id: generateNumber(), email: generateEmail(), authToken: User.AuthToken(token: generateString()))
    }
    
    override func tearDown() {
        user = nil
    }
    
    func testDecoding() {
        let jsonString = "{\"id\":\(user.id),\"email\":\"\(user.email)\",\"auth_token\":{\"token\":\"\(user.authToken!.token)\"}}"
        let jsonData = jsonString.data(using: .utf8)!
        let decodedUser = try! JSONDecoder().decode(User.self, from: jsonData)
        XCTAssertEqual(decodedUser.id, user.id)
        XCTAssertEqual(decodedUser.email, user.email)
        XCTAssertEqual(decodedUser.authToken!.token, user.authToken!.token)
    }
    
    func testUserDefaultsPersistence() {
        let defaults = UserDefaults.standard
        User.current = user
        XCTAssertEqual(User.current!.id, user.id)
        XCTAssertEqual(defaults.integer(forKey: "com.jzzocc.crystal-clipboard.user-defaults.user-id"), user.id)
        XCTAssertEqual(User.current!.email, user.email)
        XCTAssertEqual(defaults.string(forKey: "com.jzzocc.crystal-clipboard.user-defaults.user-email"), user.email)
        User.current = nil
        XCTAssertNil(User.current)
        XCTAssertEqual(defaults.integer(forKey: "com.jzzocc.crystal-clipboard.user-defaults.user-id"), 0)
        XCTAssertNil(defaults.string(forKey: "com.jzzocc.crystal-clipboard.user-defaults.user-email"))
    }
    
    func testAuthTokenKeychainPersistence() {
        let keychain = Keychain(service: Constants.keychainService)
        User.current = nil
        User.current = user
        XCTAssertEqual(keychain["auth-token"], user.authToken!.token)
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
