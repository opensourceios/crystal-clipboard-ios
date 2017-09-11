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

class ResetPasswordViewController: ModeledViewController<ResetPasswordViewModel>, UITextFieldDelegate {
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View model inputs
        
        viewModel.email <~ emailTextField.reactive.continuousTextValues.skipNil()
        submitButton.reactive.pressed = CocoaAction(viewModel.submit)
        
        // View model outputs
        
        submitButton.reactive.isEnabled <~ viewModel.submit.isEnabled
        reactive.showLoadingHUD <~ viewModel.submit.isExecuting
        reactive.alertMessage <~ viewModel.submit.errors.map { $0.message }
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
    fileprivate var successAlert: BindingTarget<String> {
        return makeBindingTarget { controller, message in
            let action = UIAlertAction(title: "ok".localized, style: .default) { _ in
                controller.navigationController?.popViewController(animated: true)
            }
            controller.presentAlert(message: message, actions: [action])
        }
    }
}
