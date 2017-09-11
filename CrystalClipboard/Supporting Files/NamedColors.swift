//
//  NamedColors.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/11/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit

extension UIColor {
    class var crystalClipboardPurple: UIColor {
        if #available(iOS 11.0, *) {
            return UIColor(named: "Crystal Clipboard Purple")!
        } else {
            return UIColor(red: 0.302, green: 0.106, blue: 0.467, alpha: 1)
        }
    }
}
