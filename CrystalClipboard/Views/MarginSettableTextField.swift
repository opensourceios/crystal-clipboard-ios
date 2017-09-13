//
//  MarginSettableTextField.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/31/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit

class MarginSettableTextField: UITextField {
    
    // MARK: IBInspectable internal stored properties
    
    @IBInspectable
    var margin: CGFloat = 0
    
    // MARK: UITextField internal overridden methods
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: margin, dy: margin)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}
