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

// This would ideally be done using protocols / extensions, but alas, we cannot add stored properties that way

class AuthenticatingViewModel {
    enum FormError: Error {
        case invalidEmail, invalidPassword
    }
    
    // MARK: Inputs
    
    let email = ValidatingProperty<String, FormError>("") { $0.characters.count > 0 ? .valid : .invalid(.invalidEmail) }
    
    let password = ValidatingProperty<String, FormError>("") { $0.characters.count > 0 ? .valid : .invalid(.invalidPassword) }
    
    private(set) lazy var submit: Action<Void, Any, MoyaError> = Action(enabledIf: self.submitEnabled) { [unowned self] _ in
        return self.provider.reactive.request(self.request).filterSuccessfulStatusCodes().mapJSON()
    }
    
    // MARK: Outputs
    
    private(set) lazy var alertMessage: Signal<String, NoError> = self.submit.errors.map { [unowned self] in
        if let messages = $0.response?.errorData.flatMap({ $0.message }), messages.count > 0 {
            return messages.joined(separator: "\n\n")
        }
        
        return self.defaultAlertMessage
    }
    
    // MARK: Private
    
    private let provider: APIProvider
    
    private lazy var submitEnabled: Property<Bool> = Property
        .combineLatest(self.email.result, self.password.result)
        .map { !$0.isInvalid && !$1.isInvalid }
    
    // MARK: Initialization
    
    init(provider: APIProvider) {
        self.provider = provider
        
        submit.values.observeValues {
            AuthToken.current = AuthToken.includedIn(JSON: $0).first
            User.current = try? User.in(JSON: $0)
        }
    }
    
    // MARK: For Subclasses
    
    var defaultAlertMessage: String {
        fatalError("This should only be called from subclasses")
    }
    
    var request: CrystalClipboardAPI {
        fatalError("This should only be called from subclasses")
    }
}
