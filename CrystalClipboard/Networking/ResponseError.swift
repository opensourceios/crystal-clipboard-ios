//
//  ResponseError.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/22/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Foundation
import SwiftyJSON
import Moya

struct ResponseError: Error {
    let detail: String?
    let pointer: String?
    
    static func deserializeErrors(json: [String: Any]) -> [ResponseError]? {
        let swiftyJSON = JSON(json)
        guard let errors = swiftyJSON["errors"].arrayObject as? [[String: Any]] else { return nil }
        return errors.flatMap { ResponseError(json: $0) }
    }
    
    init?(json: [String: Any]) {
        let swiftyJSON = JSON(json)
        detail = swiftyJSON["detail"].string
        pointer = swiftyJSON["source"]["pointer"].string
    }
    
    var message: String? {
        guard
            let detail = detail,
            let pointer = pointer,
            let specificPointer = pointer.components(separatedBy: "/").last
            else { return nil }
        return "\(specificPointer.capitalized) \(detail)"
    }
}

extension Response {
    var errors: [ResponseError] {
        if let json = (try? mapJSON()) as? [String: Any], let errors = ResponseError.deserializeErrors(json: json) {
            return errors
        }
        
        return []
    }
    
    var combinedErrorMessages: String? {
        let combined = errors.flatMap { $0.message }.joined(separator: "\n")
        return combined.characters.count > 0 ? combined : nil
    }
}
