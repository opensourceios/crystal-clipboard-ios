//
//  SignInViewController.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/30/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit

class SignInViewController: AuthenticatingViewController {
    override func viewDidLoad() {
        viewModel = SignInViewModel(provider: provider)
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination as? ProviderSettable)?.provider = provider
    }
}
