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
    
    var adminAuthToken: String {
        switch self {
        case .staging: return keys.crystalClipboardStagingAdminAuthToken
        case .production: return keys.crystalClipboardProductionAdminAuthToken
        }
    }
}

struct Constants {
    static let environment = Environment(rawValue: Bundle.main.infoDictionary!["com.jzzocc.crystal-clipboard.environment"] as! String)!
}
