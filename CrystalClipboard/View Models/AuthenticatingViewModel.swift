//
//  AuthenticatingViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/30/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import ReactiveSwift

class AuthenticatingViewModel: ViewModelType {
    // MARK: Inputs
    
    let email = MutableProperty("")
    let password = MutableProperty("")
    
    // MARK: Actions
    
    let submit: Action<Void, Void, SubmissionError>
    
    // MARK: Initialization
    
    init(provider: APIProvider, defaultAlertMessage: String, request: @escaping (String, String) -> CrystalClipboardAPI) {
        let validInput: Property<(String, String)?> = Property
            .combineLatest(email, password)
            .map { $0.count > 0 && $1.count > 0 ? ($0, $1) : nil }

        submit = Action(unwrapping: validInput) { validEmail, validPassword in
            provider.reactive.request(request(validEmail, validPassword))
                .decode(to: User.self)
                .on(value: { User.current = $0 })
                .mapError {
                    if case let .with(response: _, remoteErrors: remoteErrors) = $0 {
                        let messages = remoteErrors.map { $0.message }
                        if messages.count > 0 {
                            return SubmissionError(message: messages.joined(separator: "\n\n"))
                        }
                    }
                    
                    return SubmissionError(message: defaultAlertMessage)
                }
                .map { _ in Void() }
        }
    }
}
