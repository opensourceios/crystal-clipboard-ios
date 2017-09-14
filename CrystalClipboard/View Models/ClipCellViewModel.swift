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
    
    // MARK: Input/Output internal stored properties
    
    let expanded: MutableProperty<Bool>
    
    // MARK: Output internal stored properties
    
    let text: Property<String>
    let createdAt: Property<String>
    
    // MARK: Action internal stored properties
    
    let copy: Action<Void, String, NoError>
    
    // MARK: Internal initializers
    
    init(clip: ClipType, expanded: Bool) {
        self.expanded = MutableProperty(expanded)
        text = Property(value: clip.text)
        createdAt = Property(value: ClipCellViewModel.dateFormatter.string(from: clip.createdAt))
        copy = Action() { SignalProducer<String, NoError>(value: clip.text) }
    }
}

private extension ClipCellViewModel {
    
    // MARK: Private constants
    
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
}
