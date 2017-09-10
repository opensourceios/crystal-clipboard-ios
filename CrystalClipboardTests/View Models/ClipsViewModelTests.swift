//
//  ClipsViewModelTests.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/30/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
import CoreData
import ReactiveSwift
import enum Result.NoError
import struct CellHelpers.ChangeSet
@testable import CrystalClipboard

class ClipsViewModelTests: CoreDataTestCase {
    static let pageSize = 25
    static let initialRemoteClips = 55
    
    var viewModel: ClipsViewModel!
    var displayPage: Signal<Int, NoError>.Observer!
    
    override func setUp() {
        super.setUp()
        viewModel = ClipsViewModel(provider: provider, persistentContainer: persistentContainer, pageSize: ClipsViewModelTests.pageSize)
        let pageSignal = Signal<Int, NoError>.pipe()
        displayPage = pageSignal.input
        viewModel.pageViewed <~ pageSignal.output
        
        try! testRemoteData.createUser(email: generateEmail(), password: generateString())
        for _ in 0..<ClipsViewModelTests.initialRemoteClips {
            try! testRemoteData.createClip(text: generateString())
        }
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testFetchesAndInsertsClips() {
        let clipsInsertedExpectation = expectation(description: "Clips inserted")
        let clipsInsertedDisposable = viewModel.changeSets.observeValues {
            XCTAssertEqual($0.insertions.count, ClipsViewModelTests.pageSize)
            clipsInsertedExpectation.fulfill()
        }
        displayPage.send(value: 0)
        waitForExpectations(timeout: 1, handler: nil)
        clipsInsertedDisposable?.dispose()
        
        let moreClipsInsertedExpectation = expectation(description: "More clips inserted")
        let moreClipsInsertedDisposable = viewModel.changeSets.observeValues {
            XCTAssertEqual($0.insertions.count, ClipsViewModelTests.pageSize)
            moreClipsInsertedExpectation.fulfill()
        }
        displayPage.send(value: 1)
        waitForExpectations(timeout: 1, handler: nil)
        moreClipsInsertedDisposable?.dispose()
        
        let remainingClipsInsertedExpectation = expectation(description: "Remaining clips inserted")
        viewModel.changeSets.observeValues {
            XCTAssertEqual($0.insertions.count, 5)
            remainingClipsInsertedExpectation.fulfill()
        }
        displayPage.send(value: 2)
        waitForExpectations(timeout: 1, handler: nil)
    }
}
