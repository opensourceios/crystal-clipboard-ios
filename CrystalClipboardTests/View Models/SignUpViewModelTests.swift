//
//  SignUpViewModelTests.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/21/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
import ReactiveSwift
import Result
@testable import CrystalClipboard

class SignUpViewModelTests: XCTestCase {
    let viewModel: SignUpViewModelType = SignUpViewModel()
    let signUpButtonEnabled = TestObserver<Bool, NoError>()
    
    override func setUp() {
        super.setUp()
        
        self.viewModel.outputs.signUpButtonEnabled.observe(self.signUpButtonEnabled.observer)
    }
    
    func testSignUpButtonEnabled() {
        self.viewModel.inputs.viewDidLoad()
        self.signUpButtonEnabled.assertValues([false])
    }
}
