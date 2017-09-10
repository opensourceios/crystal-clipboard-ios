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
    var email: String!
    
    override func setUp() {
        super.setUp()
        viewModel = ResetPasswordViewModel(provider: provider)
        email = generateEmail()
        try! testRemoteData.createUser(email: email, password: generateString())
    }
    
    override func tearDown() {
        email = nil
        viewModel = nil
        super.tearDown()
    }
    
    func testResetPasswordEnabled() {
        XCTAssertFalse(viewModel.submit.isEnabled.value)
        viewModel.email.value = generateEmail()
        XCTAssertTrue(viewModel.submit.isEnabled.value)
    }
    
    func testSuccessMessage() {
        viewModel.email.value = email
        let submitExpectation = expectation(description: "Submission successful")
        viewModel.submit.values.observeValues {
            XCTAssertEqual($0, "reset-password.will-receive-email".localized)
            submitExpectation.fulfill()
        }
        viewModel.submit.apply().start()
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testNotFoundErrorMessage() {
        viewModel.email.value = generateEmail()
        let submitExpectation = expectation(description: "Submission fails")
        viewModel.submit.errors.observeValues {
            XCTAssertEqual($0, SubmissionError(message: "reset-password.email-not-found".localized))
            submitExpectation.fulfill()
        }
        viewModel.submit.apply().start()
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testNetworkErrorMessage() {
        provider = TestAPIProvider(testRemoteData: testRemoteData, online: false)
        viewModel = ResetPasswordViewModel(provider: provider)
        
        viewModel.email.value = email
        let submitExpectation = expectation(description: "Submission fails")
        viewModel.submit.errors.observeValues {
            XCTAssertEqual($0, SubmissionError(message: "reset-password.could-not".localized))
            submitExpectation.fulfill()
        }
        viewModel.submit.apply().start()
        waitForExpectations(timeout: 1, handler: nil)
    }
}
