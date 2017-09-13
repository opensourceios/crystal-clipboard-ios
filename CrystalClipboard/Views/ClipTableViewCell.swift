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

class ClipTableViewCell: UITableViewCell, ViewModelSettable {
    
    // MARK: Type aliases
    
    typealias ViewModel = ClipCellViewModel
    
    // MARK: IBOutlet private stored properties
    
    @IBOutlet
    private weak var clipTextLabel: UILabel!
    
    @IBOutlet
    private weak var createdAtLabel: UILabel!
    
    @IBOutlet
    private weak var copyButton: UIButton!
    
    // MARK: ViewModelSettable internal stored properties
    
    var viewModel: ClipCellViewModel! {
        didSet {
            // View model inputs

            copyButton.reactive.pressed = CocoaAction(viewModel.copy)

            // View model outputs

            clipTextLabel.reactive.text <~ viewModel.text
            createdAtLabel.reactive.text <~ viewModel.createdAt
        }
    }
}
