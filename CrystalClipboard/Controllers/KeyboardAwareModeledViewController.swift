//
//  KeyboardAwareModeledViewController.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/14/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit
import ReactiveSwift

class KeyboardAwareModeledViewController<VM: ViewModelType>: ModeledViewController<VM> {
    
    // MARK: IBOutlet private stored properties
    
    @IBOutlet
    private weak var scrollView: UIScrollView!
    // ⬆️ Have to degenericize this class when dragging to storyboards for some reason
    
    // MARK: UIViewController overridden methods

    override func viewDidLoad() {
        super.viewDidLoad()

        let keyboardHeightChanges = NotificationCenter.default.reactive
            .notifications(forName: .UIKeyboardDidChangeFrame)
            .take(during: reactive.lifetime)
            .map { ($0.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0 }
        
        scrollView.reactive.contentInsetBottom <~ keyboardHeightChanges
    }
}


fileprivate extension Reactive where Base: UIScrollView {
    
    // MARK: Fileprivate UIScrollView reactive extensions
    
    fileprivate var contentInsetBottom: BindingTarget<CGFloat> {
        return makeBindingTarget {
            var edgeInsets = $0.contentInset
            edgeInsets.bottom = $1
            $0.contentInset = edgeInsets
            $0.scrollIndicatorInsets = edgeInsets
        }
    }
}
