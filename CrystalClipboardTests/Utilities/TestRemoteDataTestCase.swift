//
//  DataTestCase.swift
//  CrystalClipboardTests
//
//  Created by Justin Mazzocchi on 9/7/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest

class TestRemoteDataTestCase: XCTestCase {
    
    // MARK: Internal stored properties
    
    var testRemoteData: TestRemoteData!
    
    // MARK: XCTestCase internal overridden methods
    
    override func setUp() {
        super.setUp()
        testRemoteData = TestRemoteData()
    }
    
    override func tearDown() {
        testRemoteData = nil
        super.tearDown()
    }
}
