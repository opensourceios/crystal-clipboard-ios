//
//  SubmissionError.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/3/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Foundation

struct SubmissionError: Error {
    let message: String
    
    init(message: String) {
        self.message = message
    }
    
    init?(responseError: ResponseError) {
        guard case let .with(response: _, remoteErrors: remoteErrors) = responseError else { return nil }
        let messages = remoteErrors.map { $0.message }
        guard messages.count > 0 else { return nil }
        
        self.init(message: messages.joined(separator: "\n\n"))
    }
}

extension SubmissionError: Equatable {
    static func ==(lhs: SubmissionError, rhs: SubmissionError) -> Bool {
        return lhs.message == rhs.message
    }
}
