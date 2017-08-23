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
}
