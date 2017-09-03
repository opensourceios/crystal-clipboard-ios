//
//  ClipTests.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/24/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
@testable import CrystalClipboard

class ClipTests: XCTestCase {
    func testDecoding() {
        let jsonData = CrystalClipboardAPI.createClip(text: "lol").sampleData
        let clip = try! APIResponseDecoder().decode(APIResponse<Clip>.self, from: jsonData).data!
        XCTAssertEqual(clip.id, 5659)
        XCTAssertEqual(clip.text, "lol")
        XCTAssertEqual(clip.createdAt, DateParser.date(from: "2017-08-20T16:33:52.100Z")!)
    }
    
    func testDecodingMany() {
        let jsonData = CrystalClipboardAPI.listClips(page: 1, pageSize: 25).sampleData
        let apiResponse = try! APIResponseDecoder().decode(APIResponse<[Clip]>.self, from: jsonData)
        let meta = apiResponse.meta!
        XCTAssertEqual(meta.currentPage, 1)
        XCTAssertEqual(meta.nextPage!, 2)
        XCTAssertNil(meta.previousPage)
        XCTAssertEqual(meta.totalPages, 4)
        XCTAssertEqual(meta.totalCount, 88)
        let clips = apiResponse.data!
        let clip = clips.first!
        XCTAssertEqual(clip.id, 9436)
        XCTAssertEqual(clip.text, "ec1eb9d60c8d136ef1085810d0fe5117")
    }
}
