//
//  _ViewModelSettable.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/11/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

/*
 In an ideal world, we would be able to pass in view models
 to view controllers and cells as a parameter in `init`,
 but UIKit is in control of their initialization.
 
 The next best thing would be to have only the `ViewModelSettable`
 protocol and be able to do something like:
 ```
 let coolViewModel = CoolViewModel(stuffHiddenFromController: stuff)
 (controller as? ModeledViewController<VM where VM ~= CoolViewModel.self>).viewModel = coolViewModel
 ```
 as described at https://github.com/apple/swift/blob/master/docs/GenericsManifesto.md#higher-kinded-types
 But Swift does not support higher-kinded types (yet).
 
 Until either of those changes, we have this as a solution for
 keeping view controllers ignorant of networking, persistence, and
 other stuff confined to view models. That way versions across
 different operating systems (iOS, macOS, maybe tvOS or watchOS)
 only need to be responsible for idiomatic presentation logic.
 */

protocol _ViewModelSettable {
    
    // MARK: Properties
    
    var _viewModel: ViewModelType! { get set }
    var viewModelType: ViewModelType.Type { get }
}
