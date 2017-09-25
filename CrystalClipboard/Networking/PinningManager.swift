//
//  PinningManager.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/25/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Alamofire

class PinningManager: SessionManager {
    
    // MARK: Internal SessionManager overridden initializers
    
    init() {
        let policies: [String: ServerTrustPolicy] = [
            Constants.environment.host: .pinPublicKeys(
                publicKeys: ServerTrustPolicy.publicKeys(),
                validateCertificateChain: true,
                validateHost: true
            )
        ]
        
        super.init(serverTrustPolicyManager: ServerTrustPolicyManager(policies: policies))
    }
}
