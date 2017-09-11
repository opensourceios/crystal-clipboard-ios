//
//  AppDelegate.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/17/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 11.0, *) {
            window?.tintColor = UIColor(named: "Crystal Clipboard Purple")
        } else {
            window?.tintColor = UIColor(red: 0.302, green: 0.106, blue: 0.467, alpha: 1)
        }
        return true
    }
}
