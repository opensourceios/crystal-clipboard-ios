//
//  ResetPasswordViewModelTests.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/30/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
import ReactiveSwift
import Result
import Moya
@testable import CrystalClipboard

class ResetPasswordViewModelTests: XCTestCase {
    static let provider = APIProvider.testingProvider()
    let viewModel = ResetPasswordViewModel(provider: provider)
    let successMessage = TestObserver<String, NoError>()
    let submissionErrors = TestObserver<SubmissionError, NoError>()
    
    override func setUp() {
        super.setUp()
        viewModel.submit.values.observe(successMessage.observer)
        viewModel.submit.errors.observe(submissionErrors.observer)
    }
    
    func testResetPasswordEnabled() {
        XCTAssertFalse(viewModel.submit.isEnabled.value)
        viewModel.email.value = "user@domain.com"
        XCTAssertTrue(viewModel.submit.isEnabled.value)
    }
    
    func testSuccessMessage() {
        viewModel.email.value = "satan@hell.org"
        viewModel.submit.apply().start()
        successMessage.assertValues(["reset-password.will-receive-email".localized])
    }
    
    func testNotFoundErrorMessage() {
        viewModel.email.value = "user@domain.org"
        viewModel.submit.apply().start()
        submissionErrors.assertValues([SubmissionError(message: "reset-password.email-not-found".localized)])
    }
    
    func testNetworkErrorMessage() {
        let offlineProvider = APIProvider.testingProvider(online: false)
        let offlineViewModel = ResetPasswordViewModel(provider: offlineProvider)
        let offlineSubmissionErrors = TestObserver<SubmissionError, NoError>()
        offlineViewModel.submit.errors.observe(offlineSubmissionErrors.observer)
        offlineViewModel.email.value = "satan@hell.org"
        offlineViewModel.submit.apply().start()
        offlineSubmissionErrors.assertValues([SubmissionError(message: "reset-password.could-not".localized)])
    }
}
