//
//  SubmissionError+Equatable.swift
//  CrystalClipboardTests
//
//  Created by Justin Mazzocchi on 9/13/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

@testable import CrystalClipboard

extension SubmissionError: Equatable {
    
    // MARK: Equatable public static methods
    
    public static func ==(lhs: SubmissionError, rhs: SubmissionError) -> Bool {
        return lhs.message == rhs.message
    }
}
