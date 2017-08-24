//
//  AuthToken.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/23/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

struct AuthToken {
    let token: String
    
    init(token: String) {
        self.token = token
    }
}

extension AuthToken: JSONDeserializable {
    static var dataType = "auth-tokens"

    static func from(JSON: [String : Any]) throws -> AuthToken {
        guard
            let attributes = JSON["attributes"] as? [String: Any],
            let token = attributes["token"] as? String
            else { throw JSONDeserializationError.invalidAttributes }
        
        return AuthToken(token: token)
    }
}
