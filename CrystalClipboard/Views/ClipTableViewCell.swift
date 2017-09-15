//
//  ClipTableViewCell.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/31/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit
import enum Result.NoError
import ReactiveSwift
import ReactiveCocoa

class ClipTableViewCell: UITableViewCell, ViewModelSettable {
    
    // MARK: Type aliases
    
    typealias ViewModel = ClipCellViewModel
    
    // MARK: IBOutlet private stored properties
    
    @IBOutlet
    private weak var textView: UITextView!
    
    @IBOutlet
    private weak var createdAtLabel: UILabel!
    
    @IBOutlet
    private weak var copyButton: UIButton!
    
    // MARK: IBOutlet fileprivate stored properties
    
    @IBOutlet
    fileprivate var textViewHeightConstraint: NSLayoutConstraint! // strong reference
    
    // MARK: Private stored properties
    
    private let expansionTapGestureRecognizer = UITapGestureRecognizer()
    private var expandToggled: Signal<Void, NoError>!
    private var expansionIndicationGradientLayer: CAGradientLayer!
    
    // MARK: ViewModelSettable internal stored properties
    
    var viewModel: ClipCellViewModel! {
        didSet {
            // View model inputs

            copyButton.reactive.pressed = CocoaAction(viewModel.copy)
            viewModel.expanded <~ expansionTapGestureRecognizer.reactive.stateChanged.map { [unowned self] _ in !self.viewModel.expanded.value }

            // View model outputs

            textView.reactive.text <~ viewModel.text
            createdAtLabel.reactive.text <~ viewModel.createdAt
            reactive.expanded <~ viewModel.expanded
        }
    }
    
    // MARK: UITableViewCell internal overridden methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.addGestureRecognizer(expansionTapGestureRecognizer)
        expandToggled = expansionTapGestureRecognizer.reactive.stateChanged.map { _ in () }
        expansionIndicationGradientLayer = CAGradientLayer()
        expansionIndicationGradientLayer.colors = [UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.cgColor]
        expansionIndicationGradientLayer.startPoint = CGPoint.zero
        expansionIndicationGradientLayer.endPoint = CGPoint(x: 0, y: 1)
        textView.layer.addSublayer(expansionIndicationGradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let expandable = textView.intrinsicContentSize.height > textViewHeightConstraint.constant
        expansionTapGestureRecognizer.isEnabled = expandable
        textView.setNeedsLayout()
        textView.layoutIfNeeded()
        expansionIndicationGradientLayer.frame = textView.bounds
        expansionIndicationGradientLayer.isHidden = !(expandable && textViewHeightConstraint.isActive)
    }
}

fileprivate extension Reactive where Base: ClipTableViewCell {
    
    // MARK: Fileprivate reactive extensions
    
    fileprivate var expanded: BindingTarget<Bool> {
        return makeBindingTarget {
            $0.textViewHeightConstraint.isActive = !$1
        }
    }
}
