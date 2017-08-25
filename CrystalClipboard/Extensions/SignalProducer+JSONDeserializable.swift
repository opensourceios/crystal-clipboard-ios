//
//  SignalProducer+JSONDeserializable.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/24/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import ReactiveSwift
import Moya

extension SignalProducerProtocol where Value == Any, Error == MoyaError {
    func mapDeserializeJSON<D: JSONDeserializable>(to: D.Type) -> SignalProducer<D, MoyaError> {
        return performDeserialization { try D.in(JSON: $0) }
    }
    
    func mapDeserializeJSON<D: JSONDeserializable>(toMany: D.Type) -> SignalProducer<[D], MoyaError> {
        return performDeserialization { D.manyIn(JSON: $0) }
    }
    
    private func performDeserialization<Z>(_ deserialization: @escaping ([String: Any]) throws -> Z) -> SignalProducer<Z, MoyaError> {
        return producer.flatMap(.latest) { any -> SignalProducer<Z, MoyaError> in
            do {
                guard let JSON = any as? [String: Any] else { throw MoyaError.underlying(JSONDeserializationError.invalidStructure, nil) }
                return SignalProducer(value: try deserialization(JSON))
            } catch {
                return SignalProducer(error: MoyaError.underlying(error, nil))
            }
        }
    }
}
