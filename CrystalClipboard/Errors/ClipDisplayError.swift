//
//  ClipDisplayError.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/9/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

enum ClipDisplayError: Error {
    case response(underlying: ResponseError)
    case persistence(underlying: Error)
}
