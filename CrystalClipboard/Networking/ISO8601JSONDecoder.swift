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
        dateDecodingStrategy = .formatted(type(of: self).dateFormatter)
    }
}

private extension ISO8601JSONDecoder {
    
    // MARK: Private constants
    
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.iso8601DateFormat
        return dateFormatter
    }()
}
