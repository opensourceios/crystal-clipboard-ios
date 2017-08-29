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
    
    private let provider: APIProvider
    
    // MARK: Inputs
    
    let email = ValidatingProperty<String, SignUpFormError>("") {
        $0.characters.count > 0 ? .valid : .invalid(.invalidEmail)
    }
    
    let password = ValidatingProperty<String, SignUpFormError>("") {
        $0.characters.count > 0 ? .valid : .invalid(.invalidPassword)
    }
    
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
    
    private(set) lazy var goToClips: Signal<Void, NoError> = self.user.combineLatest(with: self.authToken).map { _, _ in }
    
    // MARK: Private
    
    private lazy var signUpEnabled: Property<Bool> = Property
        .combineLatest(self.email.result, self.password.result)
        .map { !$0.isInvalid && !$1.isInvalid }
    
    private lazy var user: Signal<User, NoError> = self.signUp.values
        .map { try? User.in(JSON: $0) }
        .skipNil()
        .on(value: { User.current = $0 })
    
    private lazy var authToken: Signal<AuthToken, NoError> = self.signUp.values
        .map { AuthToken.includedIn(JSON: $0).first }
        .skipNil()
        .on(value: { AuthToken.current = $0 })
    
    // MARK: Initialization
    
    init(provider: APIProvider) {
        self.provider = provider
    }
}
