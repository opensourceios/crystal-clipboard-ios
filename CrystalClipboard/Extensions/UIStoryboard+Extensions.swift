//
//  UIStoryboard+Extensions.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/29/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit

extension UIStoryboard {
    convenience init(name: StoryboardNames) {
        self.init(name: name.rawValue, bundle: nil)
    }
    
    func instantiateViewController(withIdentifier identifier: ViewControllerStoryboardIdentifier) -> UIViewController {
        return self.instantiateViewController(withIdentifier: identifier.rawValue)
    }
}
