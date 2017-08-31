//
//  PersistentContainerSettable.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/31/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import CoreData

protocol PersistentContainerSettable: class {
    var persistentContainer: NSPersistentContainer! { get set }
}
