//
//  ClipCellViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/1/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import ReactiveSwift
import Result

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    return dateFormatter
}()

protocol ClipCellViewModelSettable {
    func setViewModel(_ viewModel: ClipCellViewModel)
}

// this is a struct and uses normal Swift properties rather than
// ReactiveSwift properties to minimize allocations when scrolling
struct ClipCellViewModel {
    // MARK: Inputs
    
    let copy: Action<Void, String, NoError>
    
    // MARK: Outputs
    
    let text: String
    let createdAt: String
    
    // MARK: Initialization
    
    init(clip: ClipType) {
        text = clip.text
        createdAt = dateFormatter.string(from: clip.createdAt)
        copy = Action() { SignalProducer<String, NoError>(value: clip.text) }
    }
}
