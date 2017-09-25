//
//  AnalyticsProvider.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/20/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Moya

class AnalyticsProvider: MoyaProvider<AnalyticsTarget> {
    
    // MARK: Internal MoyaProvider overridden initializers
    
    override init(endpointClosure: @escaping EndpointClosure = MoyaProvider.defaultEndpointMapping,
                  requestClosure: @escaping RequestClosure = MoyaProvider.defaultRequestMapping,
                  stubClosure: @escaping StubClosure = MoyaProvider.neverStub,
                  callbackQueue: DispatchQueue? = nil,
                  manager: Manager? = nil,
                  plugins: [PluginType] = [],
                  trackInflights: Bool = false) {
        
        super.init(endpointClosure: endpointClosure,
                   requestClosure: requestClosure,
                   stubClosure: stubClosure,
                   callbackQueue: callbackQueue,
                   manager: manager ?? PinningManager(),
                   plugins: plugins,
                   trackInflights: trackInflights)
    }
}
