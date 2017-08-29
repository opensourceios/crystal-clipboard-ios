//
//  User.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/23/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Foundation

struct User {
    let id: Int
    let email: String
    
    init(id: Int, email: String) {
        self.id = id
        self.email = email
    }
}

extension User {
    static private let idDefaultsKey = "com.jzzocc.crystal-clipboard.user-defaults.user-id"
    static private let emailDefaultsKey = "com.jzzocc.crystal-clipboard.user-defaults.user-email"
    static private var memoizedCurrentUser: User?
    
    static var current: User? {
        set {
            let defaults = UserDefaults.standard
            if let user = newValue {
                defaults.set(user.id, forKey: idDefaultsKey)
                defaults.set(user.email, forKey: emailDefaultsKey)
            } else {
                defaults.removeObject(forKey: idDefaultsKey)
                defaults.removeObject(forKey: emailDefaultsKey)
            }
            defaults.synchronize()
            memoizedCurrentUser = newValue
        }
        get {
            let defaults = UserDefaults.standard
            let id = defaults.integer(forKey: idDefaultsKey)
            
            if let currentUser = memoizedCurrentUser {
                return currentUser
            } else if id != 0, let email = defaults.string(forKey: emailDefaultsKey) {
                memoizedCurrentUser = User(id: id, email: email)
                return memoizedCurrentUser
            } else {
                return nil
            }
        }
    }
}

extension User: JSONDeserializable {
    static var JSONType = "users"
    
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
