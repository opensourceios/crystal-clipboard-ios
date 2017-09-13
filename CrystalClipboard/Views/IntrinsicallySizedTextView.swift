//
//  IntrinsicallySizedTextView.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/13/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit

class IntrinsicallySizedTextView: UITextView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addObserver(self, forKeyPath: #keyPath(UITextView.contentSize), options: [], context: nil)
    }
    
    deinit {
        removeObserver(self, forKeyPath: #keyPath(UITextView.contentSize), context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: CGSize {
        var size = contentSize
        size.width += textContainerInset.left + textContainerInset.right
        size.height += textContainerInset.top + textContainerInset.bottom
        return size
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }

}
