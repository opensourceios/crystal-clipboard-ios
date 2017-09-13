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
    
    // MARK: Internal constants
    
    static let userSignedIn = Notification.Name("com.jzzocc.crystal-clipboard.notifications.user-signed-in")
    static let userSignedOut = Notification.Name("com.jzzocc.crystal-clipboard.notifications.user-signed-out")
    static let userUpdated = Notification.Name("com.jzzocc.crystal-clipboard.notifications.user-updated")
}

struct User: Codable {
    
    // MARK: Coding key overrides
    
    enum CodingKeys: String, CodingKey {
        case id, email, authToken = "auth_token"
    }
    
    // MARK: Internal structs
    
    struct AuthToken: Codable {
        
        // MARK: Internal stored properties
        
        let token: String
    }
    
    // MARK: Internal stored properties
    
    let id: Int
    let email: String
    let authToken: AuthToken?
}

extension User {
    
    // MARK: Internal methods
    
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

private extension User {
    
    // MARK: Private constants
    
    static private let idDefaultsKey = "com.jzzocc.crystal-clipboard.user-defaults.user-id"
    static private let emailDefaultsKey = "com.jzzocc.crystal-clipboard.user-defaults.user-email"
    
    // MARK: Private static stored properties
    
    static private var memoizedCurrentUser: User?
}

extension User.AuthToken {
    
    // MARK: Internal static computed properties
    
    static var admin: User.AuthToken {
        return User.AuthToken(token: Constants.environment.adminToken)
    }
}

private extension User.AuthToken {
    
    // MARK: Private constants
    
    static private let keychainItem = "auth-token"
    
    // MARK: Private static stored properties
    
    static private var memoizedCurrentAuthToken: User.AuthToken?
}

fileprivate extension User.AuthToken {
    
    // MARK: Fileprivate static computed properties
    
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
