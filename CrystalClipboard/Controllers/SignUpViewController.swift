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
import Moya
import Keys

class SignUpViewController: UIViewController {
    private let viewModel = SignUpViewModel(provider: MoyaProvider<CrystalClipboardAdminAPI>(plugins: [AccessTokenPlugin(token: CrystalClipboardKeys().crystalClipboardStagingAdminAuthToken)]))

    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.text = viewModel.email.value
        passwordTextField.text = viewModel.password.value
        
        viewModel.email <~ emailTextField.reactive.continuousTextValues.skipNil()
        viewModel.password <~ passwordTextField.reactive.continuousTextValues.skipNil()
        
        signUpButton.reactive.pressed = CocoaAction(viewModel.signUp) { [unowned self] _ in
            return (self.viewModel.email.value, self.viewModel.password.value)
        }
        signUpButton.reactive.isEnabled <~ viewModel.signUpButtonEnabled
        viewModel.alertMessage.observeValues { [weak self] message in
            guard let me = self else { return }
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alertController.addAction(.init(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
            me.present(alertController, animated: true, completion: nil)
        }
    }

}
