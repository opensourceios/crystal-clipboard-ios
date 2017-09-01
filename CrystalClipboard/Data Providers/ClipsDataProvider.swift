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
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: managedObjectContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        try! fetchedResultsController.performFetch()
        super.init(fetchedResultsController: fetchedResultsController)
    }
    
    required init(fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>) {
        fatalError("init(fetchedResultsController:) has not been implemented")
    }
}
