//
//  CrystalClipboardAPI.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/17/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Foundation
import Moya

enum CrystalClipboardAPI {
    case signIn(email: String, password: String)
}

extension CrystalClipboardAPI : TargetType {
    
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
            return ["email": email, "password": password]
        }
    }
    
    var sampleData: Data {
        switch self {
        case .signIn: return stubbedResponse("SignIn")
        }
    }
    
    private func stubbedResponse(_ filename: String) -> Data! {
        @objc class ClassInTestBundle: NSObject {}
        let bundle = Bundle(for: ClassInTestBundle.self)
        let path = bundle.path(forResource: filename, ofType: "json")
        return (try? Data(contentsOf: URL(fileURLWithPath: path!)))
    }
    
}
