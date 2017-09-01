//
//  ClipTableViewCell.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/31/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit

class ClipTableViewCell: UITableViewCell {
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    @IBOutlet private weak var clipTextLabel: UILabel!
    @IBOutlet private weak var createdAtLabel: UILabel!
    @IBOutlet private weak var copyButton: UIButton!
    
    var clipText: String? {
        get { return clipTextLabel.text }
        set { clipTextLabel.text = newValue }
    }
    
    var createdAt: Date? {
        didSet {
            guard let createdAt = createdAt else { return }
            createdAtLabel.text = ClipTableViewCell.dateFormatter.string(from: createdAt)
        }
    }
}
