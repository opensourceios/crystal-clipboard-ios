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
        let jsonData = CrystalClipboardAPI.signIn(email: "satan@hell.org", password: "password").sampleData
        let user = try! JSONDecoder().decode(User.self, from: jsonData)
        User.current = user
        XCTAssertEqual(viewModel.transitionTo.value.storyboardName, .Main)
        XCTAssertEqual(viewModel.transitionTo.value.controllerIdentifier, .Clips)
    }
}
