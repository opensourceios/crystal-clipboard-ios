//
//  SignInViewModelTests.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/30/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
import ReactiveSwift
import enum Result.NoError
@testable import CrystalClipboard

class SignInViewModelTests: XCTestCase {
    static let provider = APIProvider.testingProvider()
    let viewModel = SignInViewModel(provider: provider)
    let submissionErrors = TestObserver<SubmissionError, NoError>()
    
    override func setUp() {
        super.setUp()
        viewModel.submit.errors.observe(submissionErrors.observer)
    }
    
    func testSignInEnabled() {
        XCTAssertFalse(viewModel.submit.isEnabled.value)
        viewModel.email.value = "user@domain.com"
        XCTAssertFalse(viewModel.submit.isEnabled.value)
        viewModel.password.value = "password"
        XCTAssertTrue(viewModel.submit.isEnabled.value)
    }
    
    func testSignInSetsCurrentUser() {
        User.current = nil
        viewModel.email.value = "satan@hell.org"
        viewModel.password.value = "password"
        viewModel.submit.apply().start()
        XCTAssertEqual(User.current!.email, "satan@hell.org")
    }
    
    func testAlertsRemoteErrors() {
        viewModel.email.value = "satin@heck.org"
        viewModel.password.value = "p"
        viewModel.submit.apply().start()
        submissionErrors.assertValues([SubmissionError(message: "The email or password provided was incorrect")])
        viewModel.email.value = "satan@hell.org"
        viewModel.submit.apply().start()
        submissionErrors.assertValues([
            SubmissionError(message: "The email or password provided was incorrect"),
            SubmissionError(message: "The email or password provided was incorrect")
            ])
        viewModel.password.value = "password"
        viewModel.submit.apply().start()
        submissionErrors.assertValues([
            SubmissionError(message: "The email or password provided was incorrect"),
            SubmissionError(message: "The email or password provided was incorrect")
            ])
    }
    
    func testAlertsNetworkError() {
        let offlineProvider = APIProvider.testingProvider(online: false)
        let offlineViewModel = SignInViewModel(provider: offlineProvider)
        let offlineSubmissionErrors = TestObserver<SubmissionError, NoError>()
        offlineViewModel.submit.errors.observe(offlineSubmissionErrors.observer)
        offlineViewModel.email.value = "satan@hell.org"
        offlineViewModel.password.value = "password"
        offlineViewModel.submit.apply().start()
        offlineSubmissionErrors.assertValues([SubmissionError(message: "sign-in.could-not".localized)])
    }
}
