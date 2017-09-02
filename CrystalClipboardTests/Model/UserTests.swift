//
//  UserTests.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/23/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
@testable import CrystalClipboard

class UserTests: XCTestCase {
    let user = User(id: 666, email: "satan@hell.org")
    
    func testJSONDeserialization() {
        let jsonData = CrystalClipboardAPI.me.sampleData
        let json = try! JSONSerialization.jsonObject(with: jsonData) as! [String: Any]
        let user = try! User.in(JSON: json)
        XCTAssertEqual(user.id, 666)
        XCTAssertEqual(user.email, "satan@hell.org")
    }
    
    func testUserDefaultsPersistence() {
        User.current = user
        XCTAssertEqual(User.current!.id, user.id)
        XCTAssertEqual(User.current!.email, user.email)
        User.current = nil
        XCTAssertNil(User.current)
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
        User.current = User(id: 666, email: "satan@gmail.com")
        waitForExpectations(timeout: 1, handler: nil)
    }
}
