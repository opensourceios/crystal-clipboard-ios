//
//  RemoteErrorMessages.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/6/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Foundation

struct RemoteErrorMessages: Codable, Error {
    struct Errors: Codable {
        let message: String
    }
    
    let errors: [Errors]
}
