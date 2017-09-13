//
//  CrystalClipboardAPI.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/17/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Moya

enum CrystalClipboardAPI {
    
    // MARK: Cases
    
    case createUser(email: String, password: String)
    case signIn(email: String, password: String)
    case signOut
    case resetPassword(email: String)
    case me
    case listClips(maxID: Int?, count: Int?)
    case createClip(text: String)
    case deleteClip(id: Int)
}

extension CrystalClipboardAPI: TargetType {
    
    // MARK: TargetType internal computed properties
    
    var baseURL: URL {
        return Constants.environment.apiURL
    }

    var task: Task {
        guard let parameters = parameters else { return .requestPlain }
        return .requestParameters(parameters: parameters, encoding: parameterEncoding)
    }

    var parameterEncoding: ParameterEncoding {
        switch self {
        case .listClips: return URLEncoding.default
        default: return JSONEncoding.default
        }
    }
    
    var headers: [String : String]? {
        return nil
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
            return ["email": email, "password": password]
        case let .signIn(email, password):
            return ["email": email, "password": password]
        case let .resetPassword(email):
            return ["email": email]
        case let .listClips(maxID, count):
            var params = [String: Int]()
            params["max_id"] = maxID
            params["count"] = count
            return params
        case let .createClip(text):
            return ["text": text]
        default: return nil
        }
    }
    
    var sampleData: Data {
        fatalError("sampleResponse should be used by the TestAPIProvider subclass instead of this")
    }
}

extension CrystalClipboardAPI: AccessTokenAuthorizable {
    
    // MARK: AccessTokenAuthorizable internal computed properties
    
    var authorizationType: AuthorizationType { return .bearer }
}
