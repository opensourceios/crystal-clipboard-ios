//
//  AppDelegate.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/17/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit
import CoreData
import PKHUD

private let HUDGracePeriod: TimeInterval = 0.5

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CrystalClipboard")
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores { storeDescription, error in
            if let error = error { fatalError("Could not load store: \(error)") }
        }
        return container
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        PKHUD.sharedHUD.gracePeriod = HUDGracePeriod
        (window?.rootViewController as? PersistentContainerSettable)?.persistentContainer = persistentContainer
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        if persistentContainer.viewContext.hasChanges {
            try? persistentContainer.viewContext.save()
        }
    }
}

