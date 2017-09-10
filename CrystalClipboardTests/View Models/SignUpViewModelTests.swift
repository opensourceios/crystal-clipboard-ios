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
    
    override func setUp() {
        super.setUp()
        viewModel = SignUpViewModel(provider: provider)
    }
    
    override func tearDown() {
        User.current = nil
        viewModel = nil
        super.tearDown()
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
        let submitExpectation = expectation(description: "Submission successful")
        viewModel.submit.values.observeValues {
            XCTAssertEqual(User.current!.email, email)
            submitExpectation.fulfill()
        }
        viewModel.submit.apply().start()
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testAlertsRemoteErrors() {
        let takenEmail = generateEmail()
        try! testRemoteData.createUser(email: takenEmail, password: generateString())
        
        viewModel.email.value = takenEmail
        viewModel.password.value = "p"
        let firstUnsuccessfulSubmissionExpectation = expectation(description: "Submission fails")
        let firstUnsuccessfulSubmissionDisposable = viewModel.submit.errors.observeValues {
            XCTAssertEqual($0, SubmissionError(message: "Email has already been taken\n\nPassword is too short (minimum is 6 characters)"))
            firstUnsuccessfulSubmissionExpectation.fulfill()
        }
        viewModel.submit.apply().start()
        waitForExpectations(timeout: 1, handler: nil)
        firstUnsuccessfulSubmissionDisposable?.dispose()
        viewModel.email.value = generateEmail()
        let secondUnsuccessfulSubmissionExpectation = expectation(description: "Submission fails")
        viewModel.submit.errors.observeValues {
            XCTAssertEqual($0, SubmissionError(message: "Password is too short (minimum is 6 characters)"))
            secondUnsuccessfulSubmissionExpectation.fulfill()
        }
        viewModel.submit.apply().start()
        waitForExpectations(timeout: 1, handler: nil)
        
        viewModel.password.value = generateString()
        let successfulSubmissionExpectation = expectation(description: "Submission successful")
        viewModel.submit.values.observeValues {
            successfulSubmissionExpectation.fulfill()
        }
        viewModel.submit.apply().start()
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testAlertsNetworkError() {
        provider = TestAPIProvider(testRemoteData: testRemoteData, online: false)
        viewModel = SignUpViewModel(provider: provider)
        
        viewModel.email.value = generateEmail()
        viewModel.password.value = generateString()
        let submitExpectation = expectation(description: "Submission fails")
        viewModel.submit.errors.observeValues {
            XCTAssertEqual($0, SubmissionError(message: "sign-up.could-not".localized))
            submitExpectation.fulfill()
        }
        viewModel.submit.apply().start()
        waitForExpectations(timeout: 1, handler: nil)
    }
}
