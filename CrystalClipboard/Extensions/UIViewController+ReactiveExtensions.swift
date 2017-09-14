//
//  UIViewController+ReactiveExtensions.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/11/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit
import ReactiveSwift
import PKHUD

extension Reactive where Base: UIViewController {
    
    // MARK: Internal reactive extensions
    
    var showLoadingHUD: BindingTarget<Bool> {
        return makeBindingTarget { $1 ? HUD.show(.progress) : HUD.hide() }
    }
    
    var alertMessage: BindingTarget<String> {
        return makeBindingTarget { $0.presentAlert(message: $1) }
    }
    
    var dismiss: BindingTarget<Void> {
        return makeBindingTarget { controller, _ in controller.dismiss(animated: true, completion: nil)}
    }
}
