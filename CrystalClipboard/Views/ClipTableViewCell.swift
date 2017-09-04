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

class ClipTableViewCell: UITableViewCell, ClipCellViewModelSettable {
    @IBOutlet private weak var clipTextLabel: UILabel!
    @IBOutlet private weak var createdAtLabel: UILabel!
    @IBOutlet private weak var copyButton: UIButton!
    
    private var viewModel: ClipCellViewModel! {
        didSet {
            // View model inputs
            
            copyButton.reactive.pressed = CocoaAction(viewModel.copy)
            
            // View model outputs
            
            clipTextLabel.reactive.text <~ viewModel.text
            createdAtLabel.reactive.text <~ viewModel.createdAt
        }
    }
    
    func setViewModel(_ viewModel: ClipCellViewModel) {
        self.viewModel = viewModel
    }
}
