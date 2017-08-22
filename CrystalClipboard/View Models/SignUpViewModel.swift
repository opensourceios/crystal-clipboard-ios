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
    
    let signUp: Action<(String, String), Response, MoyaError>
    
    // MARK: Outputs
    
    let signUpButtonEnabled: Property<Bool>
    let alertMessage: Signal<String, NoError>
    
    // MARK: Initialization
    
    init(provider: MoyaProvider<CrystalClipboardAPI>) {
        // Property initialization
        
        self.provider = provider
        
        signUp = Action { email, password in
            return provider.reactive.request(.createUser(email: email, password: password))
        }
        
        signUpButtonEnabled = Property
            .combineLatest(email.result, password.result)
            .map { email, password in !email.isInvalid && !password.isInvalid }
        
        let (alertMessage, alertMessageObserver) = Signal<String, NoError>.pipe()
        self.alertMessage = alertMessage
        self.alertMessageObserver = alertMessageObserver
        
        // Property observation
        
        signUp.values.observe { [weak self] event in
            self?.handleResponse(event: event)
        }
    }
    
    // MARK: Private
    
    private func handleResponse(event: Signal<Response, NoError>.Event) {
        switch event {
        case let .value(response):
            if let success = try? response.filterSuccessfulStatusCodes() {
                // TODO: Save auth token
            } else {
                let messages = response.errors.flatMap { $0.message }.joined(separator: "\n")
                if messages.characters.count > 0 {
                    alertMessageObserver.send(value: messages)
                }
            }
        case .failed(_):
            let message = NSLocalizedString("You could not be signed up at this time", comment: "")
            alertMessageObserver.send(value: message)
        default: break
        }
    }
}