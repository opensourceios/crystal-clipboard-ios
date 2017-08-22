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
import SwiftyJSON

class SignUpViewModel {
    enum SignUpFormError: Error {
        case invalidEmail
        case invalidPassword
    }
    
    private static let minimumPasswordLength = 6
    
    private let provider: MoyaProvider<CrystalClipboardAPI>
    private let alertMessageObserver: Signal<String, NoError>.Observer
    
    // MARK: Inputs
    
    let email = ValidatingProperty<String, SignUpFormError>("") { input in
        return input.characters.count > 0 ? .valid : .invalid(.invalidEmail)
    }
    
    let password = ValidatingProperty<String, SignUpFormError>("") { input in
        return input.characters.count >= SignUpViewModel.minimumPasswordLength ? .valid : .invalid(.invalidPassword)
    }
    
    lazy var signUpTapped: Action<Void, Void, NoError> = Action {
        return SignalProducer<Void, NoError> { [weak self] observer, _ in
            self?.request()
            observer.sendCompleted()
        }
    }
    
    // MARK: Outputs
    
    lazy var signUpButtonEnabled: Property<Bool> = Property
        .combineLatest(self.email.result, self.password.result)
        .map { email, password in !email.isInvalid && !password.isInvalid }

    let alertMessage: Signal<String, NoError>
    
    // MARK: Initialization
    
    init(provider: MoyaProvider<CrystalClipboardAPI>) {
        self.provider = provider
        
        let (alertMessage, alertMessageObserver) = Signal<String, NoError>.pipe()
        self.alertMessage = alertMessage
        self.alertMessageObserver = alertMessageObserver
    }
    
    // MARK: Private
    
    private func request() {
        // TODO: Save auth token
        _ = provider.reactive.request(.createUser(email: email.value, password: password.value))
            .on(failed: { [weak self] _ in self?.alertMessageObserver.send(value: NSLocalizedString("You could not be signed up at this time", comment: "")) })
            .filterSuccessfulStatusCodes()
            .on(failed: { [weak self] error in
                if let messages = error.response?.errors.flatMap({ $0.message }).joined(separator: "\n"), messages.characters.count > 0 {
                    self?.alertMessageObserver.send(value: messages)
                }
            })
            .mapJSON().start()
    }
}
