//
//  SignInViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/30/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

class SignInViewModel: AuthenticatingViewModel {
    private let provider: APIProvider
    
    init(provider: APIProvider) {
        self.provider = provider
        super.init(provider: provider, defaultAlertMessage: "sign-in.could-not".localized) { .signIn(email: $0, password: $1) }
    }
}

extension SignInViewModel: SegueingViewModel {
    func viewModel(segueIdentifier: SegueIdentifier?) -> ViewModelType? {
        if let segueIdentifier = segueIdentifier,
            segueIdentifier == .PushForgotPassword {
            return ResetPasswordViewModel(provider: provider)
        }
        
        return nil
    }
}
