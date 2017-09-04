//
//  AppDelegate.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/17/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CrystalClipboard")
        container.loadPersistentStores { storeDescription, error in
            if let error = error { fatalError("Could not load store: \(error)") }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        (window?.rootViewController as? PersistentContainerSettable)?.persistentContainer = persistentContainer
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        if persistentContainer.viewContext.hasChanges {
            try? persistentContainer.viewContext.save()
        }
    }
}

