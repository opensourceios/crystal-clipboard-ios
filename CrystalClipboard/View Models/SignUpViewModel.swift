//
//  SignUpViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/21/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import ReactiveSwift
import Result

class SignUpViewModel {
    enum SignUpFormError: Error {
        case invalidEmail
        case invalidPassword
    }
    
    static let minimumPasswordLength = 6
    
    // MARK: Inputs
    
    let email: ValidatingProperty<String, SignUpFormError>
    let password: ValidatingProperty<String, SignUpFormError>
    
    // MARK: Outputs
    
    let signUpButtonEnabled: Property<Bool>
    
    // MARK: Initialization
    
    init() {
        self.email = ValidatingProperty("") { input in
            return input.characters.count > 0 ? .valid : .invalid(.invalidEmail)
        }
        self.password = ValidatingProperty("") { input in
            return input.characters.count >= SignUpViewModel.minimumPasswordLength ? .valid : .invalid(.invalidPassword)
        }
        self.signUpButtonEnabled = Property
            .combineLatest(email.result, password.result)
            .map { email, password in !email.isInvalid && !password.isInvalid }
    }
}
