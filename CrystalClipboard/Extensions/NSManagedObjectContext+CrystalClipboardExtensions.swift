//
//  NSManagedObjectContext+CrystalClipboardExtensions.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/20/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
    func insertObject<O: NSManagedObject>() -> O {
        guard
            let entityName = O.entity().name,
            let object = NSEntityDescription.insertNewObject(forEntityName: entityName, into: self) as? O else {
            fatalError("Wrong object type")
        }
        
        return object
    }
    
    @discardableResult
    func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            rollback()
            return false
        }
    }
    
    func performChanges(changes: @escaping () -> ()) {
        perform {
            changes()
            self.saveOrRollback()
        }
    }
    
    func performChangesAndWait(changes: @escaping () -> ()) {
        performAndWait {
            changes()
            self.saveOrRollback()
        }
    }
}
