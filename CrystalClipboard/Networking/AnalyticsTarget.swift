//
//  Analytics.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/20/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Moya

enum AnalyticsTarget {
    
    // MARK: Cases
    
    case visit
}

extension AnalyticsTarget: TargetType {
    
    // MARK: TargetType internal computed properties
    
    var baseURL: URL {
        return Constants.environment.analyticsURL
    }
    
    var path: String {
        switch self {
        case .visit: return "/visits"
        }
    }
    
    var method: Method {
        switch self {
        case .visit: return .post
        }
    }
    
    var task: Task {
        switch self {
        case .visit: return .requestParameters(parameters: AnalyticsTarget.visitParameters, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return [
            "Ahoy-Visit": NSUUID().uuidString,
            "Ahoy-Visitor": AnalyticsTarget.visitorToken
        ]
    }
    
    var sampleData: Data {
        fatalError("Not supported")
    }
}

private extension AnalyticsTarget {
    
    // MARK: Private constants
    
    private static let platform = "iOS"
    private static let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    private static let osVersion = UIDevice.current.systemVersion
    private static let screenWidth = Int(UIScreen.main.bounds.width * UIScreen.main.scale)
    private static let screenHeight = Int(UIScreen.main.bounds.height * UIScreen.main.scale)
    private static let visitorTokenDefaultsKey = "com.jzzocc.crystal-clipboard.user-defaults.visitor-token"
    
    // MARK: Private static computed propeties
    
    private static var visitParameters: [String: Any] {
        var parameters: [String: Any] = [
            "platform": platform,
            "app_version": appVersion,
            "os_version": osVersion,
            "screen_width": screenWidth,
            "screen_height": screenHeight
        ]
        
        parameters["user_id"] = User.current?.id
        
        return parameters
    }
    
    private static var visitorToken: String {
        let userDefaults = UserDefaults.standard
        
        if let visitorToken = userDefaults.string(forKey: visitorTokenDefaultsKey) {
            return visitorToken
        } else {
            let visitorToken = NSUUID().uuidString
            userDefaults.set(visitorToken, forKey: visitorTokenDefaultsKey)
            userDefaults.synchronize()
            return visitorToken
        }
    }
}
