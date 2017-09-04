//
//  ClipCellViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/1/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import ReactiveSwift
import Result

protocol ClipCellViewModelSettable {
    func setViewModel(_ viewModel: ClipCellViewModel)
}

struct ClipCellViewModel {
    // MARK: Outputs
    
    let text: Property<String>
    let createdAt: Property<String>
    let lifetime: Lifetime
    
    // MARK: Actions
    
    let copy: Action<Void, String, NoError>
    
    // MARK: Initialization
    
    init(clip: ClipType) {
        text = Property(value: clip.text)
        createdAt = Property(value: ClipCellViewModel.dateFormatter.string(from: clip.createdAt))
        copy = Action() { SignalProducer<String, NoError>(value: clip.text) }
        let (lifetime, token) = Lifetime.make()
        self.lifetime = lifetime
        self.token = token
    }
    
    // MARK: Private
    
    private let token: Lifetime.Token
}

private extension ClipCellViewModel {
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
}
