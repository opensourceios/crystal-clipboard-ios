//
//  Constants.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/23/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Foundation
import Keys

fileprivate let keys = CrystalClipboardKeys()

enum Environment: String {
    case staging, production
    
    var host: String {
        switch self {
        case .staging: return "staging.crystalclipboard.com"
        case .production: return "crystalclipboard.com"
        }
    }
    
    var baseURL: URL {
        return URL(string: "https://\(host)")!
    }
    
    var apiURL: URL {
        return baseURL.appendingPathComponent("/api/v1")
    }
    
    var cableURL: URL {
        return URL(string: "wss://\(host)/cable")!
    }
    
    var adminToken: String {
        switch self {
        case .staging: return keys.crystalClipboardStagingAdminAuthToken
        case .production: return keys.crystalClipboardProductionAdminAuthToken
        }
    }
}

struct Constants {
    static let environment = Environment(rawValue: Bundle.main.infoDictionary!["com.jzzocc.crystal-clipboard.environment"] as! String)!
    static let keychainService = "com.jzzocc.crystal-clipboard"
    static let iso8601DateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // Apple's ISO8601DateFormatter can only do milliseconds on iOS 11
}
