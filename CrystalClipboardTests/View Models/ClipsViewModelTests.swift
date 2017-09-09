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
        let changeSetObserver = TestObserver<ChangeSet, NoError>()
        viewModel.changeSets.observe(changeSetObserver.observer)
        
        displayPage.send(value: 0)
        expect(after: 0.01, by: 0.1, description: "Clips fetched and inserted", execute: {
            XCTAssertEqual(changeSetObserver.values.first?.insertions.count, ClipsViewModelTests.pageSize)
        })
        displayPage.send(value: 1)
        expect(after: 0.1, by: 1, description: "Second page fetched", execute: {
            XCTAssertEqual(changeSetObserver.values[1].insertions.count, ClipsViewModelTests.pageSize)
        })
    }
}
