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
    
    enum SignUpResponseError: Error {
        case requestFailed
    }
    
    private static let minimumPasswordLength = 6
    
    private let provider: MoyaProvider<CrystalClipboardAdminAPI>
    private let alertMessageObserver: Signal<String, NoError>.Observer
    
    // MARK: Inputs
    
    let email: ValidatingProperty<String, SignUpFormError>
    let password: ValidatingProperty<String, SignUpFormError>
    let signUp: Action<(String, String), Response, MoyaError>
    
    // MARK: Outputs
    
    let signUpButtonEnabled: Property<Bool>
    let alertMessage: Signal<String, NoError>
    
    // MARK: Initialization
    
    init(provider: MoyaProvider<CrystalClipboardAdminAPI>) {
        self.provider = provider
        self.email = ValidatingProperty("") { input in
            return input.characters.count > 0 ? .valid : .invalid(.invalidEmail)
        }
        self.password = ValidatingProperty("") { input in
            return input.characters.count >= SignUpViewModel.minimumPasswordLength ? .valid : .invalid(.invalidPassword)
        }
        self.signUp = Action<(String, String), Response, MoyaError> { email, password in
            return provider.reactive.request(.createUser(email: email, password: password))
        }
        self.signUpButtonEnabled = Property
            .combineLatest(self.email.result, self.password.result)
            .map { email, password in !email.isInvalid && !password.isInvalid }
        let (alertMessage, alertMessageObserver) = Signal<String, NoError>.pipe()
        self.alertMessage = alertMessage
        self.alertMessageObserver = alertMessageObserver
        self.signUp.values.observe { [weak self] event in
            switch event {
            case let .value(response):
                if let success = try? response.filterSuccessfulStatusCodes() {
                    // TODO: Save auth token
                } else {
                    let messages = response.errors.flatMap { $0.message }.joined(separator: "\n")
                    if messages.characters.count > 0 {
                        self?.alertMessageObserver.send(value: messages)
                    }
                }
            case .failed(_):
                let message = NSLocalizedString("You could not be signed up at this time", comment: "")
                self?.alertMessageObserver.send(value: message)
            default: break
            }
        }
    }
}
