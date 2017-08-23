//
//  String+Localized.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/22/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
