//
//  APIResponse.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/2/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Foundation

struct APIResponse<T: Decodable>: Decodable {
    struct Meta: Decodable {
        let currentPage: Int
        let nextPage: Int?
        let previousPage: Int?
        let totalPages: Int
        let totalCount: Int
        enum CodingKeys: String, CodingKey {
            case currentPage = "current-page"
            case nextPage = "next-page"
            case previousPage = "prev-page"
            case totalPages = "total-pages"
            case totalCount = "total-count"
        }
    }
    
    let data: T
    let meta: Meta?
}
