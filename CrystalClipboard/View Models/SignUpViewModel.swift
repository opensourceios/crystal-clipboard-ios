//
//  SignUpViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/21/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

class SignUpViewModel: AuthenticatingViewModel {
    override var defaultAlertMessage: String {
        return "sign-up.could-not".localized
    }
    
    override var request: CrystalClipboardAPI {
        return .createUser(email: email.value, password: password.value)
    }
}
