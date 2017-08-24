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
    
    init(id: Int, email: String) {
        self.id = id
        self.email = email
    }
}

extension User: JSONDeserializable {
    static var dataType = "users"
    
    static func from(JSON: [String : Any]) throws -> User {
        guard
            let idString = JSON["id"] as? String,
            let id = Int(idString),
            let attributes = JSON["attributes"] as? [String: Any],
            let email = attributes["email"] as? String
            else { throw JSONDeserializationError.invalidAttributes }
        
        return User(id: id, email: email)
    }
}
