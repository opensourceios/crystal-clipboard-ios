//
//  JSONDeserializableTests.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/23/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
@testable import CrystalClipboard

class JSONDeserializableTests: XCTestCase {
    
    func testDeserialization() {
        let user = try! User.in(JSON: ["data": ["id": "666", "type": "users", "attributes": ["email": "satan@hell.org"]]])
        XCTAssertEqual(user.id, 666)
        XCTAssertEqual(user.email, "satan@hell.org")
    }
    
    func testDataMissing() {
        do {
            _ = try User.in(JSON: ["id": "666", "type": "users", "attributes": ["email": "satan@hell.org"]])
        } catch JSONDeserializationError.dataMissing {
            // correct
        } catch {
            XCTFail("Wrong error type")
        }
    }
    
    func testTypeMissing() {
        do {
            _ = try User.in(JSON: ["data": ["id": "666", "attributes": ["email": "satan@hell.org"]]])
        } catch JSONDeserializationError.typeMissing {
            // correct
        } catch {
            XCTFail("Wrong error type")
        }
    }
    
    func testWrongType() {
        do {
            _ = try User.in(JSON: ["data": ["id": "666", "type": "user", "attributes": ["email": "satan@hell.org"]]])
        } catch let JSONDeserializationError.wrongType(expected, given) {
            XCTAssertEqual(expected, "users")
            XCTAssertEqual(given, "user")
        } catch {
            XCTFail("Wrong error type")
        }
    }
    
    func testAttributeMissing() {
        do {
            _ = try User.in(JSON: ["data": ["id": "666", "type": "users"]])
        } catch let JSONDeserializationError.attributeMissing(name) {
            XCTAssertEqual(name, "email")
        } catch {
            XCTFail("Wrong error type")
        }
    }
    
    func testManyIn() {
        let json = ["data": [
            ["id": "666", "type": "users", "attributes": ["email": "satan@hell.org"]],
            ["id": "1256", "type": "auth-tokens", "attributes": ["token": "qz6oF9nHysGnkVYZccFJGZuz"]],
            ["id": "1098", "type": "users", "attributes": ["email": "baphomet@hell.org"]]
        ]] as [String: Any]
        let users = User.manyIn(JSON: json)
        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(users.first!.id, 666)
        XCTAssertEqual(users.first!.email, "satan@hell.org")
        XCTAssertEqual(users.last!.id, 1098)
        XCTAssertEqual(users.last!.email, "baphomet@hell.org")
    }
    
    func testIncludedIn() {
        let json = [
            "data": ["id": "666", "type": "users", "attributes": ["email": "satan@hell.org"]],
            "included": [["id": "1256", "type": "auth-tokens", "attributes": ["token": "qz6oF9nHysGnkVYZccFJGZuz"]]]
        ] as [String: Any]
        let authTokens = AuthToken.includedIn(JSON: json)
        XCTAssertEqual(authTokens.first!.token, "qz6oF9nHysGnkVYZccFJGZuz")
    }
}
