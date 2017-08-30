//
//  ResponseErrorData.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/22/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Foundation
import Moya

extension Response {
    var errorData: [ResponseErrorData] {
        guard let JSON = (try? mapJSON()) as? [String: Any] else { return [] }
        
        return ResponseErrorData.manyIn(JSON: JSON)
    }
}

struct ResponseErrorData: Error {
    let detail: String?
    let pointer: String?
    
    init(detail: String?, pointer: String?) {
        self.detail = detail
        self.pointer = pointer
    }
    
    var message: String? {
        guard let detail = detail else { return nil }
        if let pointer = pointer, let specificPointer = pointer.components(separatedBy: "/").last {
            return specificPointer.capitalized + " " + detail
        } else {
            return detail
        }
    }
}

extension ResponseErrorData: JSONDeserializable {
    static var JSONType = "errors"
    
    static func `in`(JSON: [String: Any]) throws -> ResponseErrorData {
        return try ResponseErrorData.from(JSON: JSON)
    }
    
    static func from(JSON: [String : Any]) throws -> ResponseErrorData {
        let detail = JSON["detail"] as? String
        let pointer = (JSON["source"] as? [String: Any])?["pointer"] as? String
        
        return ResponseErrorData(detail: detail, pointer: pointer)
    }
    
    static func manyIn(JSON: [String: Any]) -> [ResponseErrorData] {
        guard let errors = JSON["errors"] as? [[String: Any]] else { return [] }
        
        return errors.flatMap { try? ResponseErrorData.from(JSON: $0) }
    }
}
