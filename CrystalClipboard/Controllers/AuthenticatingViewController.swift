//
//  AuthenticatingViewController.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/30/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import PKHUD

class AuthenticatingViewController: ModeledViewController<AuthenticatingViewModel>, UITextFieldDelegate {
    @IBOutlet fileprivate weak var emailTextField: UITextField!
    @IBOutlet fileprivate weak var passwordTextField: UITextField!
    @IBOutlet fileprivate weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let submitAction = CocoaAction<UIButton>(viewModel.submit)
        
        // View model inputs
        
        viewModel.email <~ emailTextField.reactive.continuousTextValues.skipNil()
        viewModel.password <~ passwordTextField.reactive.continuousTextValues.skipNil()
        submitButton.reactive.pressed = submitAction
        
        // View model outputs
        
        submitButton.reactive.isEnabled <~ viewModel.submit.isEnabled
        viewModel.submit.errors.observe(on: UIScheduler()).observeValues { [unowned self] in self.presentAlert(message: $0.message) }
        submitAction.isExecuting.signal.observeValues { $0 ? HUD.show(.progress) : HUD.hide() }
        
        // Other setup
        
        emailTextField.becomeFirstResponder()
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField: passwordTextField.becomeFirstResponder()
        case passwordTextField: viewModel.submit.apply().start()
        default: break
        }
        return false
    }
}
