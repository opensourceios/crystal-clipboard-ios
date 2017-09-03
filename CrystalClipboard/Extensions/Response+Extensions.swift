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
        let apiResponse = try type(of: self).decoder.decode(APIResponse<T>.self, from: data)
        guard let apiData = apiResponse.data else {
            if let remoteErrors = apiResponse.errors {
                throw APIResponseError.with(remoteErrors)
            } else {
                throw APIResponseError.other
            }
        }
        
        return apiData
    }
}
