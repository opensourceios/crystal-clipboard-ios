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
    }
    
    // MARK: Inputs
    
    let email = ValidatingProperty<String, FormError>("") { $0.characters.count > 0 ? .valid : .invalid(.invalidEmail) }
    
    private(set) lazy var submit: Action<Void, Response, MoyaError> = Action(enabledIf: self.submitEnabled) { [unowned self] _ in
        return self.provider.reactive.request(.resetPassword(email: self.email.value)).filterSuccessfulStatusCodes()
    }
    
    // MARK: Outputs
    
    private(set) lazy var successMessage: Signal<String, NoError> = self.submit.values.map { _ in "reset-password.will-receive-email".localized }
    
    private(set) lazy var errorMessage: Signal<String, NoError> = self.submit.errors.map { $0.response?.statusCode == 404 ? "reset-password.email-not-found".localized : "reset-password.could-not".localized }
    
    // MARK: Private
    
    private let provider: APIProvider

    private lazy var submitEnabled: Property<Bool> = self.email.result.map { !$0.isInvalid }
    
    init(provider: APIProvider) {
        self.provider = provider
        
    }
}
