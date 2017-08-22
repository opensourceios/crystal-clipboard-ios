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
        return errors.flatMap { ResponseError(json: $0 ) }
    }
    
    init?(json: [String: Any]) {
        let swiftyJSON = JSON(json)
        self.detail = swiftyJSON["detail"].string
        self.pointer = swiftyJSON["source"]["pointer"].string
    }
    
    var message: String? {
        guard
            let detail = self.detail,
            let pointer = self.pointer,
            let specificPointer = pointer.components(separatedBy: "/").last
            else { return nil }
        return "\(specificPointer.capitalized) \(detail)"
    }
}

extension Response {
    var errors: [ResponseError] {
        if let json = (try? self.mapJSON()) as? [String: Any], let errors = ResponseError.deserializeErrors(json: json) {
            return errors
        }
        
        return []
    }
}
