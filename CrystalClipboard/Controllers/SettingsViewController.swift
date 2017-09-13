//
//  SettingsViewController.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/12/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit

class SettingsViewController: ModeledViewController<SettingsViewModel> {
    
    // MARK: UIViewController internal overridden methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: IBAction private methods
    
    @IBAction
    private func doneTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
