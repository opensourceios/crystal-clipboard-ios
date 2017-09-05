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
    static let provider = APIProvider.testingProvider()
    let viewModel = SignUpViewModel(provider: provider)
    let submissionErrors = TestObserver<SubmissionError, NoError>()
    
    override func setUp() {
        super.setUp()
        viewModel.submit.errors.observe(submissionErrors.observer)
    }
    
    func testSignUpEnabled() {
        XCTAssertFalse(viewModel.submit.isEnabled.value)
        viewModel.email.value = "user@domain.com"
        XCTAssertFalse(viewModel.submit.isEnabled.value)
        viewModel.password.value = "password"
        XCTAssertTrue(viewModel.submit.isEnabled.value)
    }
    
    func testSignUpSetsCurrentUser() {
        User.current = nil
        viewModel.email.value = "user@domain.org"
        viewModel.password.value = "password"
        viewModel.submit.apply().start()
        XCTAssertEqual(User.current!.email, "user@domain.org")
    }
    
    func testAlertsRemoteErrors() {
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
        let offlineProvider = APIProvider.testingProvider(online: false)
        let offlineViewModel = SignUpViewModel(provider: offlineProvider)
        let offlineSubmissionErrors = TestObserver<SubmissionError, NoError>()
        offlineViewModel.submit.errors.observe(offlineSubmissionErrors.observer)
        offlineViewModel.email.value = "user@domain.com"
        offlineViewModel.password.value = "password"
        offlineViewModel.submit.apply().start()
        offlineSubmissionErrors.assertValues([SubmissionError(message: "sign-up.could-not".localized)])
    }
}
