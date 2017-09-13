//
//  SettingsViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/12/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

struct SettingsViewModel: ViewModelType {
    
    // MARK: Private stored properties
    
    private let provider: APIProvider
    
    // MARK: Internal initializers
    
    init(provider: APIProvider) {
        self.provider = provider
    }
}
