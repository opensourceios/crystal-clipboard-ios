//
//  AppDelegate.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/17/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder {
    
    // MARK: Internal stored properties
    
    var window: UIWindow?
}

extension AppDelegate: UIApplicationDelegate {
    
    // MARK: UIApplicationDelegate internal methods
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window?.tintColor = UIColor.crystalClipboardPurple
        return true
    }
}
