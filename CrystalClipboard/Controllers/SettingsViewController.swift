//
//  SettingsViewController.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/12/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit

class SettingsViewController: ModeledViewController<SettingsViewModel> {
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: IBActions
    
    @IBAction private func doneTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
