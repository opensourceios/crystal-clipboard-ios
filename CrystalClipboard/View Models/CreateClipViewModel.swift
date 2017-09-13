//
//  CreateClipViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/11/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import CoreData
import ReactiveSwift

struct CreateClipViewModel: ViewModelType {
    
    // MARK: Input internal stored properties
    
    let text: MutableProperty<String>
    
    // MARK: Action internal stored properties
    
    let createClip: Action<Void, Void, SubmissionError>
    
    // MARK: Internal initializers
    
    init(provider: APIProvider, persistentContainer: NSPersistentContainer) {
        let text = MutableProperty("")
        self.text = text
        createClip = Action(enabledIf: text.map { $0.count > 0 }) { _ in
            return provider.reactive.request(.createClip(text: text.value))
                .decode(to: Clip.self)
                .mapError { ClipDisplayError($0) }
                .attemptMap { clip in
                    let context = persistentContainer.newBackgroundContext()
                    context.mergePolicy = NSMergePolicy.rollback
                    ManagedClip(from: clip, context: context)
                    try context.save()
                }
                .mapError {
                    if let responseError = $0.error as? ResponseError {
                        return SubmissionError(responseError: responseError) ?? SubmissionError(message: "clips.could-not-be-added".localized)
                    } else {
                        return SubmissionError(message: "clips.could-not-be-added".localized)
                    }
            }
        }
    }
}
