//
//  Analytics.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/20/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Foundation

struct Analytics {
    
    // MARK: Private stored properties
    
    private var provider = AnalyticsProvider()
}

extension Analytics {
    
    // MARK: Internal methods
    
    func visit() {
        if let lastVisitDate = Analytics.lastVisitDate,
            Date() < lastVisitDate.addingTimeInterval(Analytics.visitTokenExpirationTimeInterval) {
            return
        }
        
        provider.request(.visit) {
            guard $0.error == nil else { return }
            Analytics.lastVisitDate = Date()
        }
    }
}

private extension Analytics {
    
    // MARK: Private constants

    private static let lastVisitDateDefaultsKey = "com.jzzocc.crystal-clipboard.user-defaults.last-visit-date"
    private static let visitTokenExpirationTimeInterval: TimeInterval = 14400

    // MARK: Private static computed properties

    private static var lastVisitDate: Date? {
        get {
            return UserDefaults.standard.object(forKey: lastVisitDateDefaultsKey) as? Date
        } set {
            let userDefaults = UserDefaults.standard
            userDefaults.set(newValue, forKey: lastVisitDateDefaultsKey)
            userDefaults.synchronize()
        }
    }
}
