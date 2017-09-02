//
//  AuthTokenTests.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/23/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
@testable import CrystalClipboard

class AuthTokenTests: XCTestCase {
    func testJSONDeserialization() {
        let jsonData = CrystalClipboardAPI.signIn(email: "satan@hell.org", password: "password").sampleData
        let json = try! JSONSerialization.jsonObject(with: jsonData)
        let authToken = AuthToken.includedIn(JSON: json).first!
        XCTAssertEqual(authToken.token, "Vy5KbYX116Y1him376FvAhkw")
    }
    
    func testDecoding() {
        let jsonData = CrystalClipboardAPI.signIn(email: "satan@hell.org", password: "password").sampleData
        let authToken = try! JSONDecoder().decode(APIResponse<AuthToken>.self, from: jsonData).data
        XCTAssertEqual(authToken.token, "Vy5KbYX116Y1him376FvAhkw")
    }
    
    func testKeychainPersistence() {
        let authToken = AuthToken(token: "Vy5KbYX116Y1him376FvAhkw")
        AuthToken.current = authToken
        XCTAssertEqual(AuthToken.current!.token, authToken.token)
        AuthToken.current = nil
        XCTAssertNil(AuthToken.current)
    }
}
