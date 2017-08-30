//
//  SignInViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/30/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

class SignInViewModel: AuthenticatingViewModel {
    override var defaultAlertMessage: String {
        return "sign-in.could-not".localized
    }
    
    override var request: CrystalClipboardAPI {
        return .signIn(email: email.value, password: password.value)
    }
    
    override func saveAuthentication(JSON: Any) {
        AuthToken.current = try? AuthToken.in(JSON: JSON)
        User.current = User.includedIn(JSON: JSON).first
    }
}
