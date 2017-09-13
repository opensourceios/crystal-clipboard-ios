//
//  ClipType.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/1/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Foundation

protocol ClipType {
    
    // MARK: Properties
    
    var id: Int { get }
    var text: String { get }
    var createdAt: Date { get }
}
