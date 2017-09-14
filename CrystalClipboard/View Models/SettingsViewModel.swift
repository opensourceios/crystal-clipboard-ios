//
//  SettingsViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/12/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import CoreData
import ReactiveSwift

struct SettingsViewModel: ViewModelType {
    
    // MARK: Output internal stored properties
    
    let signedInAsText: Property<String>
    
    // MARK: Action internal stored properties
    
    let signOut: Action<Void, Void, ResponseError>
    
    // MARK: Private stored properties
    
    private let provider: APIProvider
    
    // MARK: Internal initializers
    
    init(provider: APIProvider, persistentContainer: NSPersistentContainer) {
        self.provider = provider
        
        guard let user = User.current else { fatalError("Should be authenticated") }
        
        signedInAsText = Property(value: String.localizedStringWithFormat("settings.signed-in-as".localized, user.email))
        
        signOut = Action() {
            return provider.reactive.request(.signOut).mapError { ResponseError.underlying($0) }.map { _ in () }.on(value: {
                let context = persistentContainer.newBackgroundContext()
                context.mergePolicy = NSMergePolicy.rollback
                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: ManagedClip.fetchRequest())
                batchDeleteRequest.resultType = .resultTypeObjectIDs
                if let result = ((try? context.execute(batchDeleteRequest)) as? NSBatchDeleteResult)?.result as? [NSManagedObjectID] {
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: result], into: [context])
                }
                User.current = nil
            })
        }
    }
}
