//
//  ResponseError.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/22/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Foundation
import Moya

extension Response {
    var errors: [ResponseError] {
        guard let JSON = (try? mapJSON()) as? [String: Any] else { return [] }
        
        return ResponseError.manyIn(JSON: JSON)
    }
}

struct ResponseError: Error {
    let detail: String?
    let pointer: String?
    
    init(detail: String?, pointer: String?) {
        self.detail = detail
        self.pointer = pointer
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

extension ResponseError: JSONDeserializable {
    static var dataType = "errors"
    
    static func `in`(JSON: [String: Any]) throws -> ResponseError {
        return try ResponseError.from(JSON: JSON)
    }
    
    static func from(JSON: [String : Any]) throws -> ResponseError {
        let detail = JSON["detail"] as? String
        let pointer = (JSON["source"] as? [String: Any])?["pointer"] as? String
        
        return ResponseError(detail: detail, pointer: pointer)
    }
    
    static func manyIn(JSON: [String: Any]) -> [ResponseError] {
        guard let errors = JSON["errors"] as? [[String: Any]] else { return [] }
        
        return errors.flatMap { try? ResponseError.from(JSON: $0) }
    }
}
