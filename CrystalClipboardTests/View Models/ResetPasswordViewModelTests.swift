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
    let errorMessage = TestObserver<String, NoError>()
    
    override func setUp() {
        super.setUp()
        viewModel.successMessage.observe(successMessage.observer)
        viewModel.errorMessage.observe(errorMessage.observer)
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
        errorMessage.assertValues(["reset-password.email-not-found".localized])
    }
    
    func testNetworkErrorMessage() {
        let offlineProvider = APIProvider.testingProvider(online: false)
        let offlineViewModel = ResetPasswordViewModel(provider: offlineProvider)
        let offlineErrorMessage = TestObserver<String, NoError>()
        offlineViewModel.errorMessage.observe(offlineErrorMessage.observer)
        offlineViewModel.email.value = "satan@hell.org"
        offlineViewModel.submit.apply().start()
        offlineErrorMessage.assertValues(["reset-password.could-not".localized])
    }
}
