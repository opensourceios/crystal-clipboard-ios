//
//  UIViewController+Extensions.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/30/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // MARK: Internal methods
    
    func presentAlert(title: String? = nil,
                      message: String? = nil,
                      preferredStyle: UIAlertControllerStyle = .alert,
                      actions: [UIAlertAction] = [.init(title: "ok".localized, style: .default, handler: nil)],
                      animated: Bool = true,
                      completion: (() -> Swift.Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        for action in actions {
            alertController.addAction(action)
        }
        present(alertController, animated: animated, completion: completion)
    }
}
