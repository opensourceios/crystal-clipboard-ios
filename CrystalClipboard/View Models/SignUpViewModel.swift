//
//  SignUpViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/21/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

class SignUpViewModel: AuthenticatingViewModel {
    init(provider: APIProvider) {
        super.init(provider: provider, defaultAlertMessage: "sign-up.could-not".localized) { .createUser(email: $0, password: $1) }
    }
}
