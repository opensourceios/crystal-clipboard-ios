//
//  SignInViewController.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/30/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

class SignInViewController: AuthenticatingViewController {
    override func viewDidLoad() {
        viewModel = SignInViewModel(provider: APIProvider())
        super.viewDidLoad()
    }
}
