//
//  SignUpViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/21/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import ReactiveSwift
import Result

protocol SignUpViewModelInputs {
    func viewDidLoad()
}

protocol SignUpViewModelOutputs {
    var signUpButtonEnabled: Signal<Bool, NoError> { get }
}

protocol SignUpViewModelType {
    var inputs: SignUpViewModelInputs { get }
    var outputs: SignUpViewModelOutputs { get }
}

class SignUpViewModel: SignUpViewModelInputs, SignUpViewModelOutputs {
    init() {
        self.signUpButtonEnabled = Signal.merge(
            self.viewDidLoadProperty.signal.map { _ in false }
        )
    }
    
    // MARK: Inputs
    
    let viewDidLoadProperty = MutableProperty()
    
    func viewDidLoad() {
        self.viewDidLoadProperty.value = ()
    }
    
    // MARK: Outputs
    
    let signUpButtonEnabled: Signal<Bool, NoError>
}

extension SignUpViewModel: SignUpViewModelType {
    var inputs: SignUpViewModelInputs { return self }
    var outputs: SignUpViewModelOutputs { return self }
}
