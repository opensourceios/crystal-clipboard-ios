
//
//  ISO8601JSONEncoder.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/7/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Foundation

class ISO8601JSONEncoder: JSONEncoder {
    
    // MARK: JSONEncoder internal overridden initializers
    
    override init() {
        super.init()
        dateEncodingStrategy = .formatted(Constants.ISO8601DateFormatter)
    }
}
