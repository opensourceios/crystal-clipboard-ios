//
//  SignUpViewController.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/21/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class SignUpViewController: UIViewController {
    private let viewModel = SignUpViewModel()

    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.text = self.viewModel.email.value
        self.passwordTextField.text = self.viewModel.password.value
        
        self.viewModel.email <~ self.emailTextField.reactive.continuousTextValues.skipNil()
        self.viewModel.password <~ self.passwordTextField.reactive.continuousTextValues.skipNil()
        
        self.signUpButton.reactive.isEnabled <~ self.viewModel.signUpButtonEnabled
    }

}
