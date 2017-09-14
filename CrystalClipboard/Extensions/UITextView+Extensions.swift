//
//  UITextView+Extensions.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/14/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit

extension UITextView {
    
    // MARK: IBInspectible internal computed properties
    
    @IBInspectable
    var textContainerTopInset: CGFloat {
        get { return textContainerInset.top }
        set { textContainerInset.top = newValue }
    }
    
    @IBInspectable
    var textContainerLeftInset: CGFloat {
        get { return textContainerInset.left }
        set { textContainerInset.left = newValue }
    }
    
    @IBInspectable
    var textContainerBottomInset: CGFloat {
        get { return textContainerInset.bottom }
        set { textContainerInset.bottom = newValue }
    }
    
    @IBInspectable
    var textContainerRightInset: CGFloat {
        get { return textContainerInset.right }
        set { textContainerInset.right = newValue }
    }
    
    @IBInspectable
    var lineFragmentPadding: CGFloat {
        get { return textContainer.lineFragmentPadding }
        set { textContainer.lineFragmentPadding = newValue }
    }
}
