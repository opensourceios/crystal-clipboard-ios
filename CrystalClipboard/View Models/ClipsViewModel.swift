//
//  ClipsViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/30/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import ReactiveSwift
import Moya

class ClipsViewModel {
    
    // MARK: Private
    
    private let provider: APIProvider
    
    init(provider: APIProvider) {
        self.provider = provider
    }
}
