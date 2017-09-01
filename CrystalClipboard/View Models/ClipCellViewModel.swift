//
//  ClipCellViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/1/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import ReactiveSwift
import Result

class ClipCellViewModel {
    // MARK: Inputs
    
    private(set) lazy var copy: Action<Void, String, NoError> = Action() { [unowned self] _ in
        return SignalProducer<String, NoError>(self.text.signal)
    }
    
    // MARK: Outputs
    
    let text: Property<String>
    let createdAt: Property<String>
    
    // MARK: Private
    
    private let clip: ClipType
    
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    init(clip: ClipType) {
        self.clip = clip
        text = Property(value: clip.text)
        createdAt = Property(value: type(of: self).dateFormatter.string(from: clip.createdAt))
    }
}
