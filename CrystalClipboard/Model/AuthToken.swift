//
//  AuthToken.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/23/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import SwiftyJSON

struct AuthToken {
    let token: String
    
    init(token: String) {
        self.token = token
    }
}

extension AuthToken: JSONDeserializable {
    static var dataType = "auth-tokens"

    static func from(JSON: [String : Any]) throws -> AuthToken {
        let json = SwiftyJSON.JSON(JSON)
        guard let token = json["attributes"]["token"].string else {
            throw JSONDeserializationError.attributeMissing(name: "token")
        }
        
        return AuthToken(token: token)
    }
}
