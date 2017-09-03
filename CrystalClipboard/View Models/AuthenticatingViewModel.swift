//
//  AuthenticatingViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/30/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import ReactiveSwift
import Result
import Moya

class AuthenticatingViewModel {
    enum FormError: Error {
        case invalidEmail
        case invalidPassword
        case response(APIResponseError)
    }
    
    // MARK: Inputs
    
    let email: ValidatingProperty<String, FormError>
    let password: ValidatingProperty<String, FormError>
    let submit: Action<Void, Void, FormError>
    
    // MARK: Outputs
    
    let alertMessage: Signal<String, NoError>
    
    // MARK: Initialization
    
    init(provider: APIProvider, defaultAlertMessage: String, request: @escaping (String, String) -> CrystalClipboardAPI) {
        email = ValidatingProperty("") { $0.count > 0 ? .valid : .invalid(.invalidEmail) }
        
        password = ValidatingProperty("") { $0.count > 0 ? .valid : .invalid(.invalidPassword) }
        
        let submitEnabled: Property<(String, String)?> = Property.combineLatest(email.result, password.result).map {
            guard let emailValue = $0.value, let passwordValue = $1.value else { return nil }
            return (emailValue, passwordValue)
        }

        submit = Action(unwrapping: submitEnabled) { validEmail, validPassword in
            provider.reactive.request(request(validEmail, validPassword))
                .decode(to: User.self)
                .on(value: { User.current = $0 })
                .mapError { FormError.response($0) }
                .map { _ in Void() }
        }

        alertMessage = submit.errors.map { e -> String in
            if case let .response(apiResponseError) = e, case let .with(errors) = apiResponseError {
                let messages = errors.flatMap { $0.message }
                if messages.count > 0 {
                    return messages.joined(separator: "\n\n")
                }
            }

            return defaultAlertMessage
        }
    }
}
