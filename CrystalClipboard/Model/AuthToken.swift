//
//  AuthToken.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/23/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import KeychainAccess

struct AuthToken {
    let token: String
    
    init(token: String) {
        self.token = token
    }
}

extension AuthToken {
    static private let keychainItem = "auth-token"
    static private var memoizedCurrentAuthToken: AuthToken?
    
    static var current: AuthToken? {
        set {
            Keychain(service: Constants.keychainService)[keychainItem] = newValue?.token
            memoizedCurrentAuthToken = newValue
        }
        get {
            if let currentAuthToken = memoizedCurrentAuthToken {
                return currentAuthToken
            } else if let token = Keychain(service: Constants.keychainService)[keychainItem] {
                memoizedCurrentAuthToken = AuthToken(token: token)
                return memoizedCurrentAuthToken
            } else {
                return nil
            }
        }
    }
}

extension AuthToken {
    static var admin: AuthToken {
        return AuthToken(token: Constants.environment.adminToken)
    }
}

extension AuthToken: JSONDeserializable {
    static var JSONType = "auth-tokens"

    static func from(JSON: [String : Any]) throws -> AuthToken {
        guard
            let attributes = JSON["attributes"] as? [String: Any],
            let token = attributes["token"] as? String
            else { throw JSONDeserializationError.invalidAttributes }
        
        return AuthToken(token: token)
    }
}

extension AuthToken: Decodable {
    private enum DataKeys: String, CodingKey {
        case attributes
        enum AttributeKeys: String, CodingKey {
            case token
        }
    }
    init(from decoder: Decoder) throws {
        let data = try decoder.container(keyedBy: DataKeys.self)
        let attributes = try data.nestedContainer(keyedBy: DataKeys.AttributeKeys.self, forKey: .attributes)
        token = try attributes.decode(String.self, forKey: .token)
    }
}
