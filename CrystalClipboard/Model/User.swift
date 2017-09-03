//
//  User.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/23/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Foundation
import KeychainAccess

extension Notification.Name {
    static let userSignedIn = Notification.Name("com.jzzocc.crystal-clipboard.notifications.user-signed-in")
    static let userSignedOut = Notification.Name("com.jzzocc.crystal-clipboard.notifications.user-signed-out")
    static let userUpdated = Notification.Name("com.jzzocc.crystal-clipboard.notifications.user-updated")
}

struct User {
    struct AuthToken {
        let token: String
        
        fileprivate init(token: String) {
            self.token = token
        }
    }
    let id: Int
    let email: String
    let authToken: AuthToken?
    
    init(id: Int, email: String) {
        self.id = id
        self.email = email
        authToken = nil
    }
}

extension User {
    static private let idDefaultsKey = "com.jzzocc.crystal-clipboard.user-defaults.user-id"
    static private let emailDefaultsKey = "com.jzzocc.crystal-clipboard.user-defaults.user-email"
    static private var memoizedCurrentUser: User?
    
    static var current: User? {
        set {
            let defaults = UserDefaults.standard
            let notificationName: Notification.Name
            if let user = newValue {
                if User.current == nil {
                    AuthToken.current = user.authToken
                    notificationName = .userSignedIn
                } else {
                    notificationName = .userUpdated
                }
                defaults.set(user.id, forKey: idDefaultsKey)
                defaults.set(user.email, forKey: emailDefaultsKey)
            } else {
                AuthToken.current = nil
                notificationName = .userSignedOut
                defaults.removeObject(forKey: idDefaultsKey)
                defaults.removeObject(forKey: emailDefaultsKey)
            }
            defaults.synchronize()
            memoizedCurrentUser = newValue
            NotificationCenter.default.post(name: notificationName, object: newValue)
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

extension User: Decodable {
    private enum DataKeys: String, CodingKey {
        case id
        case attributes
        enum AttributeKeys: String, CodingKey {
            case email
            case authToken = "auth-token"
        }
    }
    
    init(from decoder: Decoder) throws {
        let data = try decoder.container(keyedBy: DataKeys.self)
        let attributes = try data.nestedContainer(keyedBy: DataKeys.AttributeKeys.self, forKey: .attributes)
        let idString = try data.decode(String.self, forKey: .id)
        guard let id = Int(idString) else {
            let context = DecodingError.Context(codingPath: [DataKeys.id], debugDescription: "User id should be convertable to an integer")
            throw DecodingError.typeMismatch(Int.self, context)
        }
        let authToken: AuthToken?
        if let authTokenString = try attributes.decodeIfPresent(String.self, forKey: .authToken) {
            authToken = AuthToken(token: authTokenString)
        } else {
            authToken = nil
        }
        self.authToken = authToken
        self.id = id
        email = try attributes.decode(String.self, forKey: .email)
    }
}

extension User.AuthToken {
    static var admin: User.AuthToken {
        return User.AuthToken(token: Constants.environment.adminToken)
    }
}

fileprivate extension User.AuthToken {
    static private let keychainItem = "auth-token"
    static private var memoizedCurrentAuthToken: User.AuthToken?
    
    static fileprivate var current: User.AuthToken? {
        set {
            Keychain(service: Constants.keychainService)[keychainItem] = newValue?.token
            memoizedCurrentAuthToken = newValue
        }
        get {
            if let currentAuthToken = memoizedCurrentAuthToken {
                return currentAuthToken
            } else if let token = Keychain(service: Constants.keychainService)[keychainItem] {
                memoizedCurrentAuthToken = User.AuthToken(token: token)
                return memoizedCurrentAuthToken
            } else {
                return nil
            }
        }
    }
}
