//
//  CrystalClipboardAPI.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/17/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Moya

protocol CrystalClipboardAPI {}

enum CrystalClipboardUnauthenticatedAPI: CrystalClipboardAPI {
    case signIn(email: String, password: String)
}

enum CrystalClipboardAuthenticatedAPI: CrystalClipboardAPI {
    case me
    case listClips(page: Int, pageSize: Int)
    case createClip(text: String)
    case deleteClip(id: Int)
    case signOut
}

enum CrystalClipboardAdminAPI: CrystalClipboardAPI {
    case createUser(email: String, password: String)
    case resetPassword(email: String)
}

extension CrystalClipboardAPI where Self: TargetType {
    var baseURL: URL {
        let base = Bundle.main.infoDictionary!["com.jzzocc.crystal-clipboard.api-base-url"] as! String
        return URL(string: base)!
    }

    var task: Task {
        return .request
    }

    var parameterEncoding: ParameterEncoding {
        return JSONEncoding.default
    }
}

extension CrystalClipboardUnauthenticatedAPI: TargetType {
    var path: String {
        switch self {
        case .signIn: return "/users/sign_in"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .signIn: return .post
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .signIn(let email, let password):
            return [
                "data": [
                    "type": "authentications",
                    "attributes": [
                        "email": email,
                        "password": password
                    ]
                ]
            ]
        }
    }
}

extension CrystalClipboardAuthenticatedAPI: TargetType {
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .listClips: return URLEncoding.default
        default: return JSONEncoding.default
        }
    }
    
    var path: String {
        switch self {
        case .me: return "/me"
        case .listClips, .createClip: return "/me/clips"
        case .deleteClip(let id): return "/me/clips/\(id)"
        case .signOut: return "/users/sign_out"
        }
    }

    var method: Moya.Method {
        switch self {
        case .me, .listClips: return .get
        case .createClip: return .post
        case .deleteClip, .signOut: return .delete
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .listClips(let page, let pageSize):
            return ["page[number]": page, "page[size]": pageSize]
        case .createClip(let text):
            return [
                "data": [
                    "type": "clips",
                    "attributes": [
                        "text": text
                    ]
                ]
            ]
        default: return nil
        }
    }
}

extension CrystalClipboardAdminAPI: TargetType {
    var path: String {
        switch self {
        case .createUser: return "/users"
        case .resetPassword: return "/users/password"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .createUser, .resetPassword: return .post
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .createUser(let email, let password):
            return [
                "data": [
                    "type": "users",
                    "attributes": [
                        "email": email,
                        "password": password
                    ]
                ]
            ]
        case .resetPassword(let email):
            return [
                "data": [
                    "type": "password-resets",
                    "attributes": [
                        "email": email
                    ]
                ]
            ]
        }
    }
}
