//
//  SignInViewController.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/30/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import PKHUD

class SignInViewController: UIViewController {
    fileprivate let viewModel = SignInViewModel(provider: APIProvider())
    
    @IBOutlet fileprivate weak var emailTextField: UITextField!
    @IBOutlet fileprivate weak var passwordTextField: UITextField!
    @IBOutlet fileprivate weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let submitAction = CocoaAction<UIButton>(viewModel.submit)
        
        // View model inputs
        
        viewModel.email <~ emailTextField.reactive.continuousTextValues.skipNil()
        viewModel.password <~ passwordTextField.reactive.continuousTextValues.skipNil()
        signInButton.reactive.pressed = submitAction
        
        // View model outputs
        
        signInButton.reactive.isEnabled <~ viewModel.submit.isEnabled
        viewModel.alertMessage.observeValues { [unowned self] in self.presentAlert(message: $0) }
        submitAction.isExecuting.signal.observeValues { $0 ? HUD.show(.progress) : HUD.hide() }
        
        // Other setup
        
        emailTextField.becomeFirstResponder()
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField: passwordTextField.becomeFirstResponder()
        case passwordTextField: viewModel.submit.apply().start()
        default: break
        }
        return false
    }
}
