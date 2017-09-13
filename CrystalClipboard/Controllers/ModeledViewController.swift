//
//  ModeledViewController.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/11/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit

class ModeledViewController<VM: ViewModelType>: UIViewController, ViewModelSettable {
    
    // MARK: Type aliases
    
    typealias ViewModel = VM
    
    // MARK: Internal stored properties
    
    var viewModel: VM!
    
    // MARK: UIViewController internal overridden methods

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueIdentifier: SegueIdentifier?
        if let identifier = segue.identifier {
            segueIdentifier = SegueIdentifier(rawValue: identifier)
        } else {
            segueIdentifier = nil
        }
        
        if
            var target = (segue.destination as? _ViewModelSettable) ?? segue.destination.childViewControllers.first as? _ViewModelSettable,
            let destinationViewModel = (viewModel as? SegueingViewModel)?.viewModel(segueIdentifier: segueIdentifier) {
            // not checking `destination.viewModelType == type(of: destinationViewModel)` because
            // inheritance breaks `==` for types and `is` doesn't work for a type defined at runtime
            target._viewModel = destinationViewModel
        }
        
        super.prepare(for: segue, sender: sender)
    }
}
