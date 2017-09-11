//
//  ResetPasswordViewController.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/30/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import PKHUD

class ResetPasswordViewController: ModeledViewController<ResetPasswordViewModel>, UITextFieldDelegate {
    @IBOutlet fileprivate weak var emailTextField: UITextField!
    @IBOutlet fileprivate weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View model inputs
        
        viewModel.email <~ emailTextField.reactive.continuousTextValues.skipNil()
        submitButton.reactive.pressed = CocoaAction(viewModel.submit)
        
        // View model outputs
        
        submitButton.reactive.isEnabled <~ viewModel.submit.isEnabled
        reactive.showLoadingHUD <~ viewModel.submit.isExecuting
        reactive.errorAlert <~ viewModel.submit.errors
        reactive.successAlert <~ viewModel.submit.values
        
        // Other setup
        
        emailTextField.becomeFirstResponder()
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        viewModel.submit.apply().start()
        return false
    }
}

fileprivate extension Reactive where Base: ResetPasswordViewController {
    fileprivate var showLoadingHUD: BindingTarget<Bool> {
        return makeBindingTarget { $1 ? HUD.show(.progress) : HUD.hide() }
    }
    
    fileprivate var errorAlert: BindingTarget<SubmissionError> {
        return makeBindingTarget { $0.presentAlert(message: $1.message) }
    }
    
    fileprivate var successAlert: BindingTarget<String> {
        return makeBindingTarget { controller, message in
            let action = UIAlertAction(title: "ok".localized, style: .default) { _ in
                controller.navigationController?.popViewController(animated: true)
            }
            controller.presentAlert(message: message, actions: [action])
        }
    }
}
