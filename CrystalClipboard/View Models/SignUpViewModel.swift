//
//  SignUpViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/21/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import ReactiveSwift
import Result
import Moya

class SignUpViewModel {
    enum SignUpFormError: Error {
        case invalidEmail
        case invalidPassword
    }
    
    private static let minimumPasswordLength = 6
    
    private let provider: MoyaProvider<CrystalClipboardAPI>
    
    // MARK: Inputs
    
    let email = ValidatingProperty<String, SignUpFormError>("") { input in
        return input.characters.count > 0 ? .valid : .invalid(.invalidEmail)
    }
    
    let password = ValidatingProperty<String, SignUpFormError>("") { input in
        return input.characters.count >= SignUpViewModel.minimumPasswordLength ? .valid : .invalid(.invalidPassword)
    }
    
    lazy var signUp: Action<Void, String, MoyaError> = Action { [unowned self] _ in
        return self.provider.reactive.request(.createUser(email: self.email.value, password: self.password.value))
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .map { json in
                // TODO
                fatalError("coming soon")
        }
    }
    
    // MARK: Outputs
    
    lazy var signUpButtonEnabled: Property<Bool> = Property
        .combineLatest(self.email.result, self.password.result)
        .map { email, password in !email.isInvalid && !password.isInvalid }

    lazy var alertMessage: Signal<String, NoError> = self.signUp.errors.map { error in
        return error.response?.combinedErrorDescription ?? NSLocalizedString("You could not be signed up at this time", comment: "")
    }
    
    // MARK: Initialization
    
    init(provider: MoyaProvider<CrystalClipboardAPI>) {
        self.provider = provider
    }
}
