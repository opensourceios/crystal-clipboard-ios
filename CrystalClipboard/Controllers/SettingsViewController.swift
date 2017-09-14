//
//  SettingsViewController.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/12/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class SettingsViewController: ModeledViewController<SettingsViewModel> {
    
    // MARK: IBOutlet private stored properties
    
    @IBOutlet
    weak var signedInAsLabel: UILabel!
    
    @IBOutlet
    weak var signOutButton: UIButton!
    
    // MARK: UIViewController internal overridden methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View model inputs
        
        signedInAsLabel.reactive.text <~ viewModel.signedInAsText
        signOutButton.reactive.pressed = CocoaAction(viewModel.signOut)
        
        // View model outputs
        
        reactive.dismiss <~ viewModel.signOut.values
    }
    
    // MARK: IBAction private methods
    
    @IBAction
    private func doneTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
