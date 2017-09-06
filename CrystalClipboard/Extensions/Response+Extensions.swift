//
//  Response+Extensions.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/2/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Moya

extension Response {
    private static let decoder = APIResponseDecoder()
    
    func decode<T: Decodable>(to: T.Type) throws -> T {
        do {
            return try Response.decoder.decode(T.self, from: data)
        } catch {
            let remoteErrors = (try? Response.decoder.decode(RemoteErrors.self, from: data))?.errors ?? []
            throw ResponseError.with(response: self, remoteErrors: remoteErrors)
        }
    }
}
