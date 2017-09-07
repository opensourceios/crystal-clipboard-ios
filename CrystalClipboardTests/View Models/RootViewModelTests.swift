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
    let viewModel = RootViewModel()
    
    func testTransitionTo() {
        User.current = nil
        XCTAssertEqual(viewModel.transitionTo.value.storyboardName, .SignedOut)
        XCTAssertEqual(viewModel.transitionTo.value.controllerIdentifier, .Landing)
        User.current = User(id: 666, email: "satan@hell.org", authToken: User.AuthToken(token: "lol"))
        XCTAssertEqual(viewModel.transitionTo.value.storyboardName, .Main)
        XCTAssertEqual(viewModel.transitionTo.value.controllerIdentifier, .Clips)
    }
}
