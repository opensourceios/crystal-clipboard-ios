//
//  ClipsDataProvider.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/31/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import CoreData
import CellHelpers

class ClipsDataProvider: FetchedDataProvider {
    required init(managedObjectContext: NSManagedObjectContext) {
        let fetchRequest = ManagedClip.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ManagedClip.createdAt), ascending: false)]
        super.init(managedObjectContext: managedObjectContext, fetchRequest: fetchRequest, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    required init(managedObjectContext: NSManagedObjectContext, fetchRequest: NSFetchRequest<NSFetchRequestResult>, sectionNameKeyPath: String?, cacheName: String?) {
        fatalError("Clips data provider configures its own fetch request")
    }
}
