
//
//  ISO8601JSONEncoder.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/7/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Foundation

class ISO8601JSONEncoder: JSONEncoder {
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.iso8601DateFormat
        return dateFormatter
    }()
    
    override init() {
        super.init()
        dateEncodingStrategy = .formatted(type(of: self).dateFormatter)
    }
}
