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

class CreateClipViewController: KeyboardAwareModeledViewController<CreateClipViewModel> {
    
    // MARK: IBOutlet private stored properties
    
    @IBOutlet
    private weak var textView: UITextView!
    
    @IBOutlet
    private weak var cancelBarButtonItem: UIBarButtonItem!
    
    @IBOutlet
    private weak var doneBarButtonItem: UIBarButtonItem!
    
    // MARK: UIViewController overridden methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View model inputs
        
        viewModel.text <~ textView.reactive.continuousTextValues.skipNil()
        doneBarButtonItem.reactive.pressed = CocoaAction(viewModel.createClip)
        
        // View model outputs
        
        reactive.alertMessage <~ viewModel.createClip.errors.map { $0.message }
        reactive.dismiss <~ viewModel.createClip.values
        
        // Other setup
        
        textView.becomeFirstResponder()
    }
    
    // MARK: IBAction private methods
    
    @IBAction
    private func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
