//
//  RootViewModelTests.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/29/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
@testable import CrystalClipboard

class RootViewModelTests: XCTestCase {
    var viewModel: RootViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = RootViewModel()
    }
    
    override func tearDown() {
        User.current = nil
        viewModel = nil
        super.tearDown()
    }
    
    func testTransitionTo() {
        XCTAssertEqual(viewModel.transitionTo.value.storyboardName, .SignedOut)
        XCTAssertEqual(viewModel.transitionTo.value.controllerIdentifier, .Landing)
        User.current = User(id: generateNumber(), email: generateEmail(), authToken: User.AuthToken(token: generateString()))
        XCTAssertEqual(viewModel.transitionTo.value.storyboardName, .Main)
        XCTAssertEqual(viewModel.transitionTo.value.controllerIdentifier, .Clips)
    }
}
