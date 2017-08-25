//
//  User.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/23/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

struct User {
    let id: Int
    let email: String
    let authToken: AuthToken?
    
    init(id: Int, email: String, authToken: AuthToken?) {
        self.id = id
        self.email = email
        self.authToken = authToken
    }
}

extension User: JSONDeserializable {
    static var JSONType = "users"
    
    static func from(JSON: [String: Any], included: [[String: Any]]?) throws -> User {
        guard
            let idString = JSON["id"] as? String,
            let id = Int(idString),
            let attributes = JSON["attributes"] as? [String: Any],
            let email = attributes["email"] as? String
            else { throw JSONDeserializationError.invalidAttributes }
        
        let authToken = included?.flatMap { try? AuthToken.from(JSON: $0, included: nil) }.first
        
        return User(id: id, email: email, authToken: authToken)
    }
}
