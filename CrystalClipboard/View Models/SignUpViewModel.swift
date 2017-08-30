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
    enum FormError: Error {
        case invalidEmail, invalidPassword
    }
    
    private let provider: APIProvider
    
    // MARK: Inputs
    
    let email = ValidatingProperty<String, FormError>("") { $0.characters.count > 0 ? .valid : .invalid(.invalidEmail) }
    
    let password = ValidatingProperty<String, FormError>("") { $0.characters.count > 0 ? .valid : .invalid(.invalidPassword) }
    
    private(set) lazy var signUp: Action<Void, Any, MoyaError> = Action(enabledIf: self.signUpEnabled) { [unowned self] _ in
        return self.provider.reactive.request(.createUser(email: self.email.value, password: self.password.value))
            .filterSuccessfulStatusCodes()
            .mapJSON()
    }
    
    // MARK: Outputs

    private(set) lazy var alertMessage: Signal<String, NoError> = self.signUp.errors.map { error in
        if let messages = error.response?.errorData.flatMap({ $0.message }), messages.count > 0 {
            return messages.joined(separator: "\n\n")
        }
        
        return "sign-up.could-not".localized
    }
    
    // MARK: Private
    
    private lazy var signUpEnabled: Property<Bool> = Property
        .combineLatest(self.email.result, self.password.result)
        .map { !$0.isInvalid && !$1.isInvalid }
    
    // MARK: Initialization
    
    init(provider: APIProvider) {
        self.provider = provider
        
        signUp.values.observeValues {
            AuthToken.current = AuthToken.includedIn(JSON: $0).first
            User.current = try? User.in(JSON: $0)
        }
    }
}
