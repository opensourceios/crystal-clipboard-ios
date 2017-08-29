//
//  RootViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/29/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import ReactiveSwift

class RootViewModel {
    // MARK: Outputs
    
    var initialStoryboardName: Property<StoryboardNames> {
        return User.current == nil ? Property(value: .SignedOut) : Property(value: .Main)
    }
    
    var initialViewControllerIdentifier: Property<ViewControllerStoryboardIdentifier> {
        return User.current == nil ? Property(value: .Landing) : Property(value: .Clips)
    }
}
