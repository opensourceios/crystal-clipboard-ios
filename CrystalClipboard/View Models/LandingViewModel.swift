//
//  LandingViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/21/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

struct LandingViewModel: ViewModelType {
    var provider: APIProvider
}

extension LandingViewModel: SegueingViewModel {
    func viewModel(segueIdentifier: SegueIdentifier?) -> ViewModelType? {
        guard let segueIdentifier = segueIdentifier else { return nil }
        switch segueIdentifier {
        case .PushSignIn: return SignInViewModel(provider: provider)
        case .PushSignUp: return SignUpViewModel(provider: provider)
        default: return nil
        }
    }
}
