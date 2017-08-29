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
    
    func testInitialIdentifiers() {
        User.current = User(id: 666, email: "satan@hell.org")
        XCTAssertEqual(viewModel.initialStoryboardName.value, .Main)
        XCTAssertEqual(viewModel.initialViewControllerIdentifier.value, .Clips)
        User.current = nil
        XCTAssertEqual(viewModel.initialStoryboardName.value, .SignedOut)
        XCTAssertEqual(viewModel.initialViewControllerIdentifier.value, .Landing)
    }
}
