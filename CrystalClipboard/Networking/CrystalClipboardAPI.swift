//
//  CrystalClipboardAPI.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/17/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Moya

typealias APIProvider = MoyaProvider<CrystalClipboardAPI>

extension MoyaProvider where Target == CrystalClipboardAPI {
    convenience init(authToken: AuthToken) {
        self.init(plugins: [AccessTokenPlugin(token: authToken.token)])
    }
    
    static func adminProvider() -> APIProvider {
        return APIProvider(authToken: AuthToken.admin)
    }
    
    static func userProvider() -> APIProvider? {
        guard let authToken = AuthToken.current else { return nil }
        return APIProvider(authToken: authToken)
    }
}

enum CrystalClipboardAPI {
    case createUser(email: String, password: String)
    case signIn(email: String, password: String)
    case signOut
    case resetPassword(email: String)
    case me
    case listClips(page: Int, pageSize: Int)
    case createClip(text: String)
    case deleteClip(id: Int)
}

extension CrystalClipboardAPI: TargetType {
    var baseURL: URL {
        return Constants.environment.apiURL
    }

    var task: Task {
        return .request
    }

    var parameterEncoding: ParameterEncoding {
        switch self {
        case .listClips: return URLEncoding.default
        default: return JSONEncoding.default
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/vnd.api+json"]
    }
    
    var path: String {
        switch self {
        case .createUser: return "/users"
        case .signIn: return "/users/sign_in"
        case .signOut: return "/users/sign_out"
        case .resetPassword: return "/users/password"
        case .me: return "/me"
        case .listClips, .createClip: return "/me/clips"
        case let .deleteClip(id): return "/me/clips/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .createUser, .signIn, .resetPassword, .createClip: return .post
        case .me, .listClips: return .get
        case .signOut, .deleteClip: return .delete
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case let .createUser(email, password):
            return ["data": ["type": "users", "attributes": ["email": email, "password": password]]]
        case let .signIn(email, password):
            return ["data": ["type": "authentications", "attributes": ["email": email, "password": password]]]
        case let .resetPassword(email):
            return ["data": ["type": "password-resets", "attributes": ["email": email]]]
        case let .listClips(page, pageSize):
            return ["page[number]": page, "page[size]": pageSize]
        case let .createClip(text):
            return ["data": ["type": "clips", "attributes": ["text": text]]]
        default: return nil
        }
    }
}
