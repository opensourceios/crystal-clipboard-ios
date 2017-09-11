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

struct User: Codable {
    enum CodingKeys: String, CodingKey {
        case id, email, authToken = "auth_token"
    }
    struct AuthToken: Codable {
        let token: String
        
        init(token: String) {
            self.token = token
        }
    }
    let id: Int
    let email: String
    let authToken: AuthToken?
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
                memoizedCurrentUser = User(id: id, email: email, authToken: AuthToken.current)
                return memoizedCurrentUser
            } else {
                return nil
            }
        }
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
