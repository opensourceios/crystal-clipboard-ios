//
//  ResetPasswordViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/30/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import ReactiveSwift

struct ResetPasswordViewModel: ViewModelType {
    
    // MARK: Input internal stored properties
    
    let email = MutableProperty("")
    
    // MARK: Action internal stored properties
    
    let submit: Action<Void, String, SubmissionError>
    
    // MARK: Internal initializers
    
    init(provider: APIProvider) {
        let validInput: Property<String?> = email.map { $0.count > 0 ? $0 : nil }
        
        submit = Action(unwrapping: validInput) { validEmail in
            provider.reactive.request(.resetPassword(email: validEmail))
                .filterSuccessfulStatusCodes()
                .mapError {
                    if $0.response?.statusCode == 404 {
                        return SubmissionError(message: "reset-password.email-not-found".localized)
                    } else {
                        return SubmissionError(message: "reset-password.could-not".localized)
                    }
                }
                .map { _ in "reset-password.will-receive-email".localized }
        }
    }
}
