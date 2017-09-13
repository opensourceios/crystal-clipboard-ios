//
//  ResponseError.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/6/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Foundation
import class Moya.Response

struct RemoteError: Error, Codable {
    
    // MARK: Internal stored properties
    
    let message: String
}

struct RemoteErrors: Error, Codable {
    
    // MARK: Internal stored properties
    
    let errors: [RemoteError]
}

enum ResponseError: Error {
    
    // MARK: Cases
    
    case with(response: Response, remoteErrors: [RemoteError])
    case underlying(Error)
}
