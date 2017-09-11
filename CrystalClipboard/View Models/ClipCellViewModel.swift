//
//  ClipCellViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/1/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import ReactiveSwift
import enum Result.NoError

struct ClipCellViewModel: ViewModelType {
    // MARK: Outputs
    
    let text: Property<String>
    let createdAt: Property<String>
    
    // MARK: Actions
    
    let copy: Action<Void, String, NoError>
    
    // MARK: Initialization
    
    init(clip: ClipType) {
        text = Property(value: clip.text)
        createdAt = Property(value: ClipCellViewModel.dateFormatter.string(from: clip.createdAt))
        copy = Action() { SignalProducer<String, NoError>(value: clip.text) }
    }
}

private extension ClipCellViewModel {
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
}
