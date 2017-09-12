//
//  CreateClipViewController.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/11/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class CreateClipViewController: ModeledViewController<CreateClipViewModel> {
    
    // MARK: IBOutlets
    
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var doneBarButtonItem: UIBarButtonItem!
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View model inputs
        
        viewModel.text <~ textView.reactive.continuousTextValues.skipNil()
        doneBarButtonItem.reactive.pressed = CocoaAction(viewModel.createClip)
        
        // View model outputs
        
        reactive.alertMessage <~ viewModel.createClip.errors.map { $0.message }
        reactive.dismiss <~ viewModel.createClip.values
        
        // Other setup
        
        let keyboardHeightChanges = NotificationCenter.default.reactive
            .notifications(forName: .UIKeyboardDidChangeFrame)
            .take(during: reactive.lifetime)
            .map { ($0.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0 }
        textView.reactive.contentInsetBottom <~ keyboardHeightChanges
        
        textView.becomeFirstResponder()
    }
    
    // MARK: IBActions
    
    @IBAction private func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: Fileprivate UIScrollView reactive extensions

fileprivate extension Reactive where Base: UIScrollView {
    fileprivate var contentInsetBottom: BindingTarget<CGFloat> {
        return makeBindingTarget {
            var edgeInsets = $0.contentInset
            edgeInsets.bottom = $1
            $0.contentInset = edgeInsets
            $0.scrollIndicatorInsets = edgeInsets
        }
    }
}

// MARK: Fileprivate reactive extensions

fileprivate extension Reactive where Base: CreateClipViewController {
    fileprivate var dismiss: BindingTarget<Void> {
        return makeBindingTarget { controller, _ in controller.dismiss(animated: true, completion: nil)}
    }
}
