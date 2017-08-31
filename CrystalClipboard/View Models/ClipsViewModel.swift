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

class ClipsViewModel {
    
    // MARK: Private
    
    private let provider: APIProvider
    private let persistentContainer: NSPersistentContainer
    
    // MARK: Initialization
    
    init(provider: APIProvider, persistentContainer: NSPersistentContainer) {
        self.provider = provider
        self.persistentContainer = persistentContainer
    }
}
