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
import Moya
@testable import CrystalClipboard

class SignUpViewModelTests: XCTestCase {
    static let provider = CrystalClipboardAPI.testingProvider()
    let viewModel = SignUpViewModel(provider: provider)
    let alertMessage = TestObserver<String, NoError>()
    
    override func setUp() {
        super.setUp()
        viewModel.alertMessage.observe(alertMessage.observer)
    }
    
    func testSignUpButtonEnabled() {
        XCTAssertFalse(viewModel.signUpButtonEnabled.value)
        viewModel.email.value = "user@domain.com"
        XCTAssertFalse(viewModel.signUpButtonEnabled.value)
        viewModel.password.value = "123"
        XCTAssertFalse(viewModel.signUpButtonEnabled.value)
        viewModel.password.value = "123456"
        XCTAssertTrue(viewModel.signUpButtonEnabled.value)
    }
    
    func testSignUp() {
        viewModel.signUp.apply(("satan@hell.org", "password")).start()
        // TODO
    }
    
    func testSignUpEmailTaken() {
        viewModel.signUp.apply(("satan@hell.org", "password")).start()
        alertMessage.assertValues(["Email has already been taken"])
        viewModel.signUp.apply(("satan@hell.org", "password")).start()
        alertMessage.assertValues(["Email has already been taken", "Email has already been taken"])
        viewModel.signUp.apply(("satan+2@hell.org", "password")).start()
        alertMessage.assertValues(["Email has already been taken", "Email has already been taken"])
    }
}
