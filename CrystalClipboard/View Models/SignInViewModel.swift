//
//  SignInViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/30/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

class SignInViewModel: AuthenticatingViewModel {
    init(provider: APIProvider) {
        super.init(provider: provider, defaultAlertMessage: "sign-in.could-not".localized) { .signIn(email: $0, password: $1) }
    }
}
