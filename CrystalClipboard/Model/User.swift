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
        guard let stringId = JSON["id"] as? String else { throw JSONDeserializationError.idMissing }
        guard let id = Int(stringId) else { throw JSONDeserializationError.idInvalid }
        guard let attributes = JSON["attributes"] as? [String: Any] else { throw JSONDeserializationError.attributesMissing }
        guard let presentEmail = attributes["email"] else { throw JSONDeserializationError.attributeMissing(name: "email") }
        guard let email = presentEmail as? String else { throw JSONDeserializationError.wrongAttributeType(name: "email", expected: String.self, given: type(of: presentEmail)) }
        
        return User(id: id, email: email)
    }
}
