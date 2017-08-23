//
//  User.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/23/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import SwiftyJSON

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
    
    static func from(JSON: [String : Any]) -> User {
        let json = SwiftyJSON.JSON(JSON)
        let id = json["id"].intValue
        let email = json["attributes"]["email"].stringValue
        
        return User(id: id, email: email)
    }
}
