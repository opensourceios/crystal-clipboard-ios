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
    
    // MARK: Internal stored properties
    
    let fetchedResultsController: NSFetchedResultsController<ManagedClip>
    
    // MARK: Internal initializers
    
    init(managedObjectContext: NSManagedObjectContext) {
        let fetchRequest = ManagedClip.fetchRequest() as! NSFetchRequest<ManagedClip>
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ManagedClip.id), ascending: false)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: managedObjectContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        try! fetchedResultsController.performFetch()
        self.fetchedResultsController = fetchedResultsController
    }
}
