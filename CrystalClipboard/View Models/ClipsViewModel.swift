//
//  ClipsViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/30/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import CoreData
import ReactiveSwift
import Moya

fileprivate let pageSize = 25

class ClipsViewModel {
    
    // MARK: Inputs
    
    private(set) lazy var fetchClips: Action<Void, Any, MoyaError> = Action() { _ in
        return self.provider.reactive.request(.listClips(page: 1, pageSize: pageSize)).filterSuccessfulStatusCodes().mapJSON()
    }
    
    // MARK: Private
    
    private let provider: APIProvider
    private let persistentContainer: NSPersistentContainer
    
    // MARK: Initialization
    
    init(provider: APIProvider, persistentContainer: NSPersistentContainer) {
        self.provider = provider
        self.persistentContainer = persistentContainer
        
        fetchClips.values.observeValues {
            let clips = Clip.manyIn(JSON: $0)
            persistentContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergePolicy.rollback
                for clip in clips {
                    ManagedClip(from: clip, context: context)
                }
                try? context.save()
            }
        }
    }
}
