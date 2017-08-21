//
//  SignUpViewModelTests.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/21/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
import ReactiveSwift
import Result
@testable import CrystalClipboard

class SignUpViewModelTests: XCTestCase {
    let viewModel = SignUpViewModel()
    
    func testSignUpButtonEnabled() {
        XCTAssertFalse(viewModel.signUpButtonEnabled.value)
        viewModel.email.value = "user@domain.com"
        XCTAssertFalse(viewModel.signUpButtonEnabled.value)
        viewModel.password.value = "123"
        XCTAssertFalse(viewModel.signUpButtonEnabled.value)
        viewModel.password.value = "123456"
        XCTAssertTrue(viewModel.signUpButtonEnabled.value)
    }
}
