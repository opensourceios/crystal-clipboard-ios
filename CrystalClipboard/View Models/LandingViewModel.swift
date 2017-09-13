//
//  LandingViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/21/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

struct LandingViewModel: ViewModelType {
    
    // MARK: Private stored properties
    
    private var provider: APIProvider
    
    // MARK: Internal initializers
    
    init(provider: APIProvider) {
        self.provider = provider
    }
}

extension LandingViewModel: SegueingViewModel {
    
    // MARK: SegueingViewModel internal methods
    
    func viewModel(segueIdentifier: SegueIdentifier?) -> ViewModelType? {
        guard let segueIdentifier = segueIdentifier else { return nil }
        switch segueIdentifier {
        case .PushSignIn: return SignInViewModel(provider: provider)
        case .PushSignUp: return SignUpViewModel(provider: provider)
        default: return nil
        }
    }
}
