//
//  DataTestCase.swift
//  CrystalClipboardTests
//
//  Created by Justin Mazzocchi on 9/7/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest

class DataTestCase: XCTestCase {
    var testData: TestData!
    
    override func setUp() {
        super.setUp()
        testData = TestData()
    }
    
    override func tearDown() {
        testData = nil
        super.tearDown()
    }
}
