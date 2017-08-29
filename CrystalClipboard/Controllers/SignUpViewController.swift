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
    private let viewModel = SignUpViewModel(provider: APIProvider.adminProvider())

    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View model inputs
        
        viewModel.email <~ emailTextField.reactive.continuousTextValues.skipNil()
        viewModel.password <~ passwordTextField.reactive.continuousTextValues.skipNil()
        signUpButton.reactive.pressed = CocoaAction(viewModel.signUp)
        
        // View model outputs
        
        signUpButton.reactive.isEnabled <~ viewModel.signUp.isEnabled
        viewModel.alertMessage.observeValues { [weak self] in
            self?.displayAlert(message: $0)
        }
    }
    
    // MARK: Private
    
    private func displayAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(.init(title: "ok".localized, style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
