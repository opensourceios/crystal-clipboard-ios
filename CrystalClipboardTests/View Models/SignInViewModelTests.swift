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
    var email: String!
    var password: String!
    
    override func setUp() {
        super.setUp()
        viewModel = SignInViewModel(provider: provider)
        email = generateEmail()
        password = generateString()
        try! testRemoteData.createUser(email: email, password: password)
    }
    
    override func tearDown() {
        User.current = nil
        password = nil
        email = nil
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
        let submitExpectation = expectation(description: "Submission successful")
        viewModel.submit.values.observeValues { [unowned self] in
            XCTAssertEqual(User.current?.email, self.email)
            submitExpectation.fulfill()
        }
        viewModel.submit.apply().start()
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testAlertsRemoteErrors() {
        viewModel.email.value = generateEmail()
        viewModel.password.value = generateString()
        let firstUnsuccessfulSubmissionExpectation = expectation(description: "Submission fails")
        let firstUnsuccessfulSubmissionDisposable = viewModel.submit.errors.observeValues {
            XCTAssertEqual($0, SubmissionError(message: "The email or password provided was incorrect"))
            firstUnsuccessfulSubmissionExpectation.fulfill()
        }
        viewModel.submit.apply().start()
        waitForExpectations(timeout: 1, handler: nil)
        firstUnsuccessfulSubmissionDisposable?.dispose()
        
        viewModel.email.value = email
        let secondUnsuccessfulSubmissionExpectation = expectation(description: "Submission fails")
        viewModel.submit.errors.observeValues {
            XCTAssertEqual($0, SubmissionError(message: "The email or password provided was incorrect"))
            secondUnsuccessfulSubmissionExpectation.fulfill()
        }
        viewModel.submit.apply().start()
        waitForExpectations(timeout: 1, handler: nil)
        
        viewModel.password.value = password
        let successfulSubmissionExpectation = expectation(description: "Submission successful")
        viewModel.submit.values.observeValues {
            successfulSubmissionExpectation.fulfill()
        }
        viewModel.submit.apply().start()
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testAlertsNetworkError() {
        provider = TestAPIProvider(testRemoteData: testRemoteData, online: false)
        viewModel = SignInViewModel(provider: provider)
        
        viewModel.email.value = email
        viewModel.password.value = password
        let submitExpectation = expectation(description: "Submission fails")
        viewModel.submit.errors.observeValues {
            XCTAssertEqual($0, SubmissionError(message: "sign-in.could-not".localized))
            submitExpectation.fulfill()
        }
        viewModel.submit.apply().start()
        waitForExpectations(timeout: 1, handler: nil)
    }
}
