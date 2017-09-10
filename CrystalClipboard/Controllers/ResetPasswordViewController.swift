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

class ResetPasswordViewController: UIViewController, ProviderSettable {
    var provider: APIProvider!
    
    fileprivate lazy var viewModel: ResetPasswordViewModel = ResetPasswordViewModel(provider: self.provider)
    
    @IBOutlet fileprivate weak var emailTextField: UITextField!
    @IBOutlet fileprivate weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let submitAction = CocoaAction<UIButton>(viewModel.submit)
        let scheduler = UIScheduler()
        
        // View model inputs
        
        viewModel.email <~ emailTextField.reactive.continuousTextValues.skipNil()
        submitButton.reactive.pressed = submitAction
        
        // View model outputs
        
        submitButton.reactive.isEnabled <~ viewModel.submit.isEnabled
        submitAction.isExecuting.signal.observeValues { $0 ? HUD.show(.progress) : HUD.hide() }
        
        viewModel.submit.errors.observe(on: scheduler).observeValues { [unowned self] in self.presentAlert(message: $0.message) }
        viewModel.submit.values.observe(on: scheduler).observeValues { [unowned self] in
            let action = UIAlertAction(title: "ok".localized, style: .default) { [unowned self] _ in
                self.navigationController?.popViewController(animated: true)
            }
            self.presentAlert(message: $0, actions: [action])
        }
        
        // Other setup
        
        emailTextField.becomeFirstResponder()
    }
}

extension ResetPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        viewModel.submit.apply().start()
        return false
    }
}
