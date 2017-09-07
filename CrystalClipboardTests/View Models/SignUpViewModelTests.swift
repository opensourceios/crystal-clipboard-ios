//
//  SignUpViewModelTests.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/21/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
import ReactiveSwift
import enum Result.NoError
@testable import CrystalClipboard

class SignUpViewModelTests: XCTestCase {
    var provider: TestAPIProvider!
    var viewModel: SignUpViewModel!
    var submissionErrors: TestObserver<SubmissionError, NoError>!
    
    override func setUp() {
        super.setUp()
        provider = TestAPIProvider()
        viewModel = SignUpViewModel(provider: provider)
        submissionErrors = TestObserver()
        viewModel.submit.errors.observe(submissionErrors.observer)
    }
    
    func testSignUpEnabled() {
        XCTAssertFalse(viewModel.submit.isEnabled.value)
        viewModel.email.value = "satan@hell.org"
        XCTAssertFalse(viewModel.submit.isEnabled.value)
        viewModel.password.value = "password"
        XCTAssertTrue(viewModel.submit.isEnabled.value)
    }
    
    func testSignUpSetsCurrentUser() {
        User.current = nil
        viewModel.email.value = "satan@hell.org"
        viewModel.password.value = "password"
        viewModel.submit.apply().start()
        XCTAssertEqual(User.current!.email, "satan@hell.org")
    }
    
    func testAlertsRemoteErrors() {
        provider.request(.createUser(email: "satan@hell.org", password: "password"))
        viewModel.email.value = "satan@hell.org"
        viewModel.password.value = "p"
        viewModel.submit.apply().start()
        submissionErrors.assertValues([SubmissionError(message: "Email has already been taken\n\nPassword is too short (minimum is 6 characters)")])
        viewModel.email.value = "satan+2@hell.org"
        viewModel.submit.apply().start()
        submissionErrors.assertValues([
            SubmissionError(message: "Email has already been taken\n\nPassword is too short (minimum is 6 characters)"),
            SubmissionError(message: "Password is too short (minimum is 6 characters)")
        ])
        viewModel.password.value = "password"
        viewModel.submit.apply().start()
        submissionErrors.assertValues([
            SubmissionError(message: "Email has already been taken\n\nPassword is too short (minimum is 6 characters)"),
            SubmissionError(message: "Password is too short (minimum is 6 characters)")
        ])
    }
    
    func testAlertsNetworkError() {
        provider = TestAPIProvider(online: false)
        viewModel = SignUpViewModel(provider: provider)
        submissionErrors = TestObserver<SubmissionError, NoError>()
        viewModel.submit.errors.observe(submissionErrors.observer)
        
        viewModel.email.value = "user@domain.com"
        viewModel.password.value = "password"
        viewModel.submit.apply().start()
        submissionErrors.assertValues([SubmissionError(message: "sign-up.could-not".localized)])
    }
}
