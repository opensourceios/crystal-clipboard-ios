//
//  SignUpViewController.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/21/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

class SignUpViewController: AuthenticatingViewController {
    override lazy var viewModel: AuthenticatingViewModel = {
        return SignUpViewModel(provider: provider)
    }()
}
