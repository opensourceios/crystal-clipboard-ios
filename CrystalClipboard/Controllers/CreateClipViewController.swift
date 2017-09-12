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
    
    @IBOutlet private weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default.reactive
        let keyboardHeightChanges = notificationCenter.notifications(forName: .UIKeyboardDidChangeFrame)
            .take(during: reactive.lifetime)
            .map { ($0.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? CGRect)?.height ?? 0 }
        let keyboardHides = notificationCenter.notifications(forName: .UIKeyboardDidHide)
            .take(during: reactive.lifetime)
            .map { _ in CGFloat(0) }
        let keyboardHeight = SignalProducer(values: keyboardHeightChanges, keyboardHides).flatten(.merge)
        textView.reactive.contentInsetBottom <~ keyboardHeight
        
        textView.becomeFirstResponder()
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

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
