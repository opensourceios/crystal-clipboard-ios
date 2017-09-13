//
//  RemoteErrors+Equatable.swift
//  CrystalClipboardTests
//
//  Created by Justin Mazzocchi on 9/8/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

@testable import CrystalClipboard

extension RemoteError: Equatable {
    
    // MARK: Equatable public static methods
    
    public static func ==(lhs: RemoteError, rhs: RemoteError) -> Bool {
        return lhs.message == rhs.message
    }
}

extension RemoteErrors: Equatable {
    
    // MARK: Equatable public static methods
    
    public static func ==(lhs: RemoteErrors, rhs: RemoteErrors) -> Bool {
        return lhs.errors == rhs.errors
    }
}
