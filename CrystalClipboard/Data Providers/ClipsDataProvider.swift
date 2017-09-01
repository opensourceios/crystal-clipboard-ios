//
//  ClipsDataProvider.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/31/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import CoreData
import CellHelpers

struct ClipsDataProvider: FetchedDataProvider {
    let fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>
    
    init(managedObjectContext: NSManagedObjectContext) {
        let fetchRequest = ManagedClip.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ManagedClip.createdAt), ascending: false)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: managedObjectContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        try! fetchedResultsController.performFetch()
        self.fetchedResultsController = fetchedResultsController
    }
}
