//
//  ISO8601JSONDecoder.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/2/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Foundation

class ISO8601JSONDecoder: JSONDecoder {
    
    // MARK: JSONDecoder internal overridden initializers
    
    override init() {
        super.init()
        dateDecodingStrategy = .formatted(Constants.ISO8601DateFormatter)
    }
}
