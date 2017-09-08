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

class SignInViewModelTests: ProviderTestCase {
    var viewModel: SignInViewModel!
    var submissionErrors: TestObserver<SubmissionError, NoError>!
    var email: String!
    var password: String!
    
    override func setUp() {
        super.setUp()
        viewModel = SignInViewModel(provider: provider)
        submissionErrors = TestObserver()
        viewModel.submit.errors.observe(submissionErrors.observer)
        email = generateEmail()
        password = generateString()
        try! testRemoteData.createUser(email: email, password: password)
    }
    
    override func tearDown() {
        password = nil
        email = nil
        submissionErrors = nil
        viewModel = nil
        provider = nil
    }
    
    func testSignInEnabled() {
        XCTAssertFalse(viewModel.submit.isEnabled.value)
        viewModel.email.value = generateEmail()
        XCTAssertFalse(viewModel.submit.isEnabled.value)
        viewModel.password.value = generateString()
        XCTAssertTrue(viewModel.submit.isEnabled.value)
    }
    
    func testSignInSetsCurrentUser() {
        User.current = nil
        viewModel.email.value = email
        viewModel.password.value = password
        viewModel.submit.apply().start()
        XCTAssertEqual(User.current!.email, email)
    }
    
    func testAlertsRemoteErrors() {
        viewModel.email.value = generateEmail()
        viewModel.password.value = generateString()
        viewModel.submit.apply().start()
        submissionErrors.assertValues([SubmissionError(message: "The email or password provided was incorrect")])
        viewModel.email.value = email
        viewModel.submit.apply().start()
        submissionErrors.assertValues([
            SubmissionError(message: "The email or password provided was incorrect"),
            SubmissionError(message: "The email or password provided was incorrect")
            ])
        viewModel.password.value = password
        viewModel.submit.apply().start()
        submissionErrors.assertValues([
            SubmissionError(message: "The email or password provided was incorrect"),
            SubmissionError(message: "The email or password provided was incorrect")
            ])
    }
    
    func testAlertsNetworkError() {
        provider = TestAPIProvider(testRemoteData: testRemoteData, online: false)
        viewModel = SignInViewModel(provider: provider)
        submissionErrors = TestObserver()
        
        viewModel.submit.errors.observe(submissionErrors.observer)
        viewModel.email.value = email
        viewModel.password.value = password
        viewModel.submit.apply().start()
        submissionErrors.assertValues([SubmissionError(message: "sign-in.could-not".localized)])
    }
}
