//
//  ResetPasswordViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/30/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import ReactiveSwift
import Result
import Moya

class ResetPasswordViewModel {
    enum FormError: Error {
        case invalidEmail
        case response(MoyaError)
    }
    
    // MARK: Inputs
    
    let email: ValidatingProperty<String, FormError>
    
    let submit: Action<Void, Void, FormError>
    
    // MARK: Outputs
    
    let successMessage: Signal<String, NoError>
    
    let errorMessage: Signal<String, NoError>
    
    // MARK: Initialization
    
    init(provider: APIProvider) {
        email = ValidatingProperty("") { $0.characters.count > 0 ? .valid : .invalid(.invalidEmail) }
        
        let validInput: Property<String?> = email.result.map { $0.value }
        
        submit = Action(unwrapping: validInput) { validEmail in
            provider.reactive.request(.resetPassword(email: validEmail))
                .filterSuccessfulStatusCodes()
                .mapError { FormError.response($0) }
                .map {_ in Void() }
        }
        
        successMessage = submit.values.map { _ in "reset-password.will-receive-email".localized }
        errorMessage = submit.errors.map {
            if case let .response(responseError) = $0, responseError.response?.statusCode == 404 {
                return "reset-password.email-not-found".localized
            } else {
                return "reset-password.could-not".localized }
        }
    }
}
