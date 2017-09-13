//
//  SignalProducer+Extensions.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/2/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import ReactiveSwift
import Moya

extension SignalProducerProtocol where Value == Response {
    
    // MARK: Internal methods
    
    func decode<T: Decodable>(to: T.Type) -> SignalProducer<T, ResponseError> {
        return producer
            .mapError { ResponseError.underlying($0) }
            .flatMap(.latest) { response -> SignalProducer<T, ResponseError> in
                do { return SignalProducer(value: try response.decode(to: T.self)) }
                catch { return SignalProducer(error: error as? ResponseError ?? ResponseError.underlying(error)) }
        }
    }
}
