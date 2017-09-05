//
//  Response+ExtensionsTests.swift
//  CrystalClipboardTests
//
//  Created by Justin Mazzocchi on 9/2/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
@testable import CrystalClipboard

class Response_ExtensionsTests: XCTestCase {
    func testDecode() {
        APIProvider.testingProvider().request(.me) { result in
            switch result {
            case let .success(response):
                let user = try! response.decode(to: User.self)
                XCTAssertEqual(user.id, 666)
            case .failure: XCTFail("Should be a successful response")
            }
        }
    }
    
    func testDecodeWithPageInfo() {
        APIProvider.testingProvider().request(.listClips(page: 1, pageSize: 25)) { result in
            switch result {
            case let .success(response):
                let (clips, pageInfo) = try! response.decodeWithPageInfo(to: [Clip].self)
                XCTAssertEqual(clips.count, 25)
                XCTAssertEqual(pageInfo.currentPage, 1)
                XCTAssertEqual(pageInfo.nextPage, 2)
                XCTAssertNil(pageInfo.previousPage)
                XCTAssertEqual(pageInfo.totalCount, 88)
                XCTAssertEqual(pageInfo.totalPages, 4)
            case .failure: XCTFail("Should be a successful response")
            }
        }
    }
}
