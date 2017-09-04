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
}

extension SubmissionError: Equatable {
    static func ==(lhs: SubmissionError, rhs: SubmissionError) -> Bool {
        return lhs.message == rhs.message
    }
}
