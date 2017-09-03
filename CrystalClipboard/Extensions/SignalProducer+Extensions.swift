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
    func decode<T: Decodable>(to: T.Type) -> SignalProducer<T, APIResponseError<T>> {
        return producer
            .mapError { APIResponseError<T>.underlying($0) }
            .flatMap(.latest) { response -> SignalProducer<T, APIResponseError<T>> in
                do {
                    return SignalProducer(value: try response.decode(to: T.self))
                } catch {
                    return SignalProducer(error: error as? APIResponseError<T> ?? APIResponseError<T>.underlying(error))
                }
        }
    }
}
