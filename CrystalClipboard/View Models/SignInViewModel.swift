//
//  SignInViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/30/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

class SignInViewModel: AuthenticatingViewModel {
    
    // MARK: Private stored properties
    
    private let provider: APIProvider
    
    // MARK: Internal initializers
    
    init(provider: APIProvider) {
        self.provider = provider
        super.init(provider: provider, defaultAlertMessage: "sign-in.could-not".localized) { .signIn(email: $0, password: $1) }
    }
}

extension SignInViewModel: SegueingViewModel {
    
    // MARK: SegueingViewModel internal methods
    
    func viewModel(segueIdentifier: SegueIdentifier?) -> ViewModelType? {
        if let segueIdentifier = segueIdentifier,
            segueIdentifier == .PushForgotPassword {
            return ResetPasswordViewModel(provider: provider)
        }
        
        return nil
    }
}
