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

class AuthenticatingViewController: ModeledViewController<AuthenticatingViewModel>, UITextFieldDelegate {
    
    // MARK: IBOutlet private stored properties
    
    @IBOutlet
    private weak var emailTextField: UITextField!
    
    @IBOutlet
    private weak var passwordTextField: UITextField!
    
    @IBOutlet
    private weak var submitButton: UIButton!
    
    // MARK: UIViewController internal overridden methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View model inputs
        
        viewModel.email <~ emailTextField.reactive.continuousTextValues.skipNil()
        viewModel.password <~ passwordTextField.reactive.continuousTextValues.skipNil()
        submitButton.reactive.pressed = CocoaAction(viewModel.submit)
        
        // View model outputs
        
        submitButton.reactive.isEnabled <~ viewModel.submit.isEnabled
        reactive.alertMessage <~ viewModel.submit.errors.map { $0.message }
        reactive.showLoadingHUD <~ viewModel.submit.isExecuting
        
        // Other setup
        
        emailTextField.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: UITextFieldDelegate internal methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField: passwordTextField.becomeFirstResponder()
        case passwordTextField: viewModel.submit.apply().start()
        default: break
        }
        return false
    }
}
