//
//  SegueingViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/11/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

protocol SegueingViewModel: ViewModelType {
    
    // MARK: Methods
    
    func viewModel(segueIdentifier: SegueIdentifier?) -> ViewModelType?
}
