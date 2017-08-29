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
    
    let initialStoryboardName: Property<StoryboardNames> = Property(value: .SignedOut)
    
    let initialViewControllerIdentifier: Property<ViewControllerStoryboardIdentifier> = Property(value: .Landing)
}
