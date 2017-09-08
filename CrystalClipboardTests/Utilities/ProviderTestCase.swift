//
//  ProviderTestCase.swift
//  CrystalClipboardTests
//
//  Created by Justin Mazzocchi on 9/7/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest

class ProviderTestCase: TestRemoteDataTestCase {
    var provider: TestAPIProvider!
    
    override func setUp() {
        super.setUp()
        provider = TestAPIProvider(testRemoteData: testRemoteData)
    }
    
    override func tearDown() {
        provider = nil
        super.tearDown()
    }
}
