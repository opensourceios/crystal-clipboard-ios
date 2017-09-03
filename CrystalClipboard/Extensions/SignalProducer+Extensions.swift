//
//  SignalProducer+Extensions.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/2/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import ReactiveSwift
import Moya
import Result

extension SignalProducerProtocol where Value == Response {
    func decode<T: Decodable>(to: T.Type) -> SignalProducer<T, APIResponseError> {
        return producer
            .mapError { APIResponseError.underlying($0) }
            .flatMap(.latest) { response -> SignalProducer<T, APIResponseError> in
                do {
                    return SignalProducer(value: try response.decode(to: T.self))
                } catch {
                    return SignalProducer(error: error as? APIResponseError ?? APIResponseError.underlying(error))
                }
        }
    }
    
    func decode<T: Decodable, I: Decodable>(to: T.Type, included: I.Type) -> SignalProducer<(T, [I]), APIResponseError> {
        return producer
            .mapError { APIResponseError.underlying($0) }
            .flatMap(.latest) { response -> SignalProducer<(T, [I]), APIResponseError> in
                do {
                    return SignalProducer(value: try response.decode(to: T.self, included: I.self))
                } catch {
                    return SignalProducer(error: error as? APIResponseError ?? APIResponseError.underlying(error))
                }
        }
    }
}
