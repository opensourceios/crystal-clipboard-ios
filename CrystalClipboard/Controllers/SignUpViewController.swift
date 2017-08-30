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
import PKHUD

class SignUpViewController: UIViewController {
    fileprivate let viewModel = SignUpViewModel(provider: APIProvider.adminProvider())

    @IBOutlet fileprivate weak var emailTextField: UITextField!
    @IBOutlet fileprivate weak var passwordTextField: UITextField!
    @IBOutlet fileprivate weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let submitAction = CocoaAction<UIButton>(viewModel.submit)
        
        // View model inputs
        
        viewModel.email <~ emailTextField.reactive.continuousTextValues.skipNil()
        viewModel.password <~ passwordTextField.reactive.continuousTextValues.skipNil()
        signUpButton.reactive.pressed = submitAction
        
        // View model outputs
        
        signUpButton.reactive.isEnabled <~ viewModel.submit.isEnabled
        viewModel.alertMessage.observeValues { [unowned self] in self.presentAlert(message: $0) }
        submitAction.isExecuting.signal.observeValues { $0 ? HUD.show(.progress) : HUD.hide() }
        
        // Other setup
        
        emailTextField.becomeFirstResponder()
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField: passwordTextField.becomeFirstResponder()
        case passwordTextField: viewModel.submit.apply().start()
        default: break
        }
        return false
    }
}
