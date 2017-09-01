//
//  ClipTableViewCell.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/31/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class ClipTableViewCell: UITableViewCell {
    @IBOutlet private weak var clipTextLabel: UILabel!
    @IBOutlet private weak var createdAtLabel: UILabel!
    @IBOutlet private weak var copyButton: UIButton!
    
    var viewModel: ClipCellViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            setup(fromViewModel: viewModel)
        }
    }
    
    private func setup(fromViewModel model: ClipCellViewModel) {
        // View model inputs
        
        copyButton.reactive.pressed = CocoaAction(model.copy)
        
        // View model outputs
        
        clipTextLabel.text = model.text
        createdAtLabel.text = model.createdAt
    }
}
