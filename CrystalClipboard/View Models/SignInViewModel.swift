//
//  SignInViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/30/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import ReactiveSwift
import Result
import Moya

class SignInViewModel {
    enum FormError: Error {
        case invalidEmail, invalidPassword
    }
    
    // MARK: Inputs
    
    let email = ValidatingProperty<String, FormError>("") { $0.characters.count > 0 ? .valid : .invalid(.invalidEmail) }
    
    let password = ValidatingProperty<String, FormError>("") { $0.characters.count > 0 ? .valid : .invalid(.invalidPassword) }
    
    private(set) lazy var signIn: Action<Void, Any, MoyaError> = Action(enabledIf: self.signInEnabled) { [unowned self] _ in
        return self.provider.reactive.request(.signIn(email: self.email.value, password: self.password.value))
            .filterSuccessfulStatusCodes()
            .mapJSON()
    }
    
    // MARK: Outputs
    
    private(set) lazy var alertMessage: Signal<String, NoError> = self.signIn.errors.map {
        if let messages = $0.response?.errorData.flatMap({ $0.message }), messages.count > 0 {
            return messages.joined(separator: "\n\n")
        }
        
        return "sign-in.could-not".localized
    }
    
    // MARK: Private
    
    private let provider: APIProvider
    
    private lazy var signInEnabled: Property<Bool> = Property
        .combineLatest(self.email.result, self.password.result)
        .map { !$0.isInvalid && !$1.isInvalid }
    
    // MARK: Initialization
    
    init(provider: APIProvider) {
        self.provider = provider
        
        signIn.values.observeValues {
            AuthToken.current = try? AuthToken.in(JSON: $0)
            User.current = User.includedIn(JSON: $0).first
        }
    }
}
