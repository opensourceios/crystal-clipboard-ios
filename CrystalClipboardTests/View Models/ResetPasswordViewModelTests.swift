//
//  ResetPasswordViewModelTests.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/30/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
import ReactiveSwift
import enum Result.NoError
@testable import CrystalClipboard

class ResetPasswordViewModelTests: ProviderTestCase {
    var viewModel: ResetPasswordViewModel!
    var successMessage: TestObserver<String, NoError>!
    var submissionErrors: TestObserver<SubmissionError, NoError>!
    
    override func setUp() {
        super.setUp()
        viewModel = ResetPasswordViewModel(provider: provider)
        successMessage = TestObserver()
        submissionErrors = TestObserver()
        viewModel.submit.values.observe(successMessage.observer)
        viewModel.submit.errors.observe(submissionErrors.observer)
    }
    
    override func tearDown() {
        submissionErrors = nil
        successMessage = nil
        viewModel = nil
        super.tearDown()
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
        provider = TestAPIProvider(testData: testData, online: false)
        viewModel = ResetPasswordViewModel(provider: provider)
        successMessage = nil
        submissionErrors = TestObserver<SubmissionError, NoError>()
        viewModel.submit.errors.observe(submissionErrors.observer)
        
        viewModel.email.value = "satan@hell.org"
        viewModel.submit.apply().start()
        submissionErrors.assertValues([SubmissionError(message: "reset-password.could-not".localized)])
    }
}
