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
    private let viewModel = SignUpViewModel(provider: APIProvider.adminProvider())

    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let signUpAction = CocoaAction<UIButton>(viewModel.signUp)
        
        // View model inputs
        
        viewModel.email <~ emailTextField.reactive.continuousTextValues.skipNil()
        viewModel.password <~ passwordTextField.reactive.continuousTextValues.skipNil()
        signUpButton.reactive.pressed = signUpAction
        
        // View model outputs
        
        signUpButton.reactive.isEnabled <~ viewModel.signUp.isEnabled
        viewModel.alertMessage.observeValues { [unowned self] in self.presentAlert(message: $0) }
        signUpAction.isExecuting.signal.observeValues { $0 ? HUD.show(.progress) : HUD.hide() }
    }
}
