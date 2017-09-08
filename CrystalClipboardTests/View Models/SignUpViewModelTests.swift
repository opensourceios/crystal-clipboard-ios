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

class SignUpViewModelTests: ProviderTestCase {
    var viewModel: SignUpViewModel!
    var submissionErrors: TestObserver<SubmissionError, NoError>!
    
    override func setUp() {
        super.setUp()
        viewModel = SignUpViewModel(provider: provider)
        submissionErrors = TestObserver()
        viewModel.submit.errors.observe(submissionErrors.observer)
    }
    
    func testSignUpEnabled() {
        XCTAssertFalse(viewModel.submit.isEnabled.value)
        viewModel.email.value = generateEmail()
        XCTAssertFalse(viewModel.submit.isEnabled.value)
        viewModel.password.value = generateString()
        XCTAssertTrue(viewModel.submit.isEnabled.value)
    }
    
    func testSignUpSetsCurrentUser() {
        User.current = nil
        let email = generateEmail()
        viewModel.email.value = email
        viewModel.password.value = generateString()
        viewModel.submit.apply().start()
        XCTAssertEqual(User.current!.email, email)
    }
    
    func testAlertsRemoteErrors() {
        let takenEmail = generateEmail()
        try! testData.createUser(email: takenEmail, password: generateString())
        
        viewModel.email.value = takenEmail
        viewModel.password.value = "p"
        viewModel.submit.apply().start()
        submissionErrors.assertValues([SubmissionError(message: "Email has already been taken\n\nPassword is too short (minimum is 6 characters)")])
        viewModel.email.value = generateEmail()
        viewModel.submit.apply().start()
        submissionErrors.assertValues([
            SubmissionError(message: "Email has already been taken\n\nPassword is too short (minimum is 6 characters)"),
            SubmissionError(message: "Password is too short (minimum is 6 characters)")
        ])
        viewModel.password.value = generateString()
        viewModel.submit.apply().start()
        submissionErrors.assertValues([
            SubmissionError(message: "Email has already been taken\n\nPassword is too short (minimum is 6 characters)"),
            SubmissionError(message: "Password is too short (minimum is 6 characters)")
        ])
    }
    
    func testAlertsNetworkError() {
        provider = TestAPIProvider(testData: testData, online: false)
        viewModel = SignUpViewModel(provider: provider)
        submissionErrors = TestObserver<SubmissionError, NoError>()
        viewModel.submit.errors.observe(submissionErrors.observer)
        
        viewModel.email.value = generateEmail()
        viewModel.password.value = generateString()
        viewModel.submit.apply().start()
        submissionErrors.assertValues([SubmissionError(message: "sign-up.could-not".localized)])
    }
}
