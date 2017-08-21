//
//  SignUpViewController.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/21/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit
import ReactiveSwift

class SignUpViewController: UIViewController {
    let viewModel: SignUpViewModelType = SignUpViewModel()

    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel.outputs.signUpButtonEnabled
            .observe(on: UIScheduler())
            .observeValues { [weak self] enabled in self?.signUpButton.isEnabled = enabled }

        viewModel.inputs.viewDidLoad()
    }

}
