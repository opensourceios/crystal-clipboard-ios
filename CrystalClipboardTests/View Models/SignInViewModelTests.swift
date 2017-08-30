//
//  SignInViewModelTests.swift
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

class SignInViewModelTests: XCTestCase {
    static let provider = APIProvider.testingProvider()
    let viewModel = SignInViewModel(provider: provider)
    let alertMessage = TestObserver<String, NoError>()
    
    override func setUp() {
        super.setUp()
        viewModel.alertMessage.observe(alertMessage.observer)
    }
    
    func testSignInEnabled() {
        XCTAssertFalse(viewModel.signIn.isEnabled.value)
        viewModel.email.value = "user@domain.com"
        XCTAssertFalse(viewModel.signIn.isEnabled.value)
        viewModel.password.value = "password"
        XCTAssertTrue(viewModel.signIn.isEnabled.value)
    }
    
    func testSignInSetsCurrentUser() {
        User.current = nil
        viewModel.email.value = "satan@hell.org"
        viewModel.password.value = "password"
        viewModel.signIn.apply().start()
        XCTAssertEqual(User.current!.email, "satan@hell.org")
    }
    
    func testAlertsRemoteErrors() {
        viewModel.email.value = "satin@heck.org"
        viewModel.password.value = "p"
        viewModel.signIn.apply().start()
        alertMessage.assertValues(["The email or password provided was incorrect"])
        viewModel.email.value = "satan@hell.org"
        viewModel.signIn.apply().start()
        alertMessage.assertValues(["The email or password provided was incorrect", "The email or password provided was incorrect"])
        viewModel.password.value = "password"
        viewModel.signIn.apply().start()
        alertMessage.assertValues(["The email or password provided was incorrect", "The email or password provided was incorrect"])
    }
    
    func testAlertsNetworkError() {
        let offlineProvider = APIProvider.testingProvider(online: false)
        let offlineViewModel = SignInViewModel(provider: offlineProvider)
        let offlineAlertMessage = TestObserver<String, NoError>()
        offlineViewModel.alertMessage.observe(offlineAlertMessage.observer)
        offlineViewModel.email.value = "satan@hell.org"
        offlineViewModel.password.value = "password"
        offlineViewModel.signIn.apply().start()
        offlineAlertMessage.assertValues(["sign-in.could-not".localized])
    }
}
