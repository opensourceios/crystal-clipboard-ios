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
    
    class Controller {
        let (pageSignal, pageObserver) = Signal<Int, NoError>.pipe()
        var viewModel: ClipsViewModel! {
            didSet {
                viewModel.pageDisplayed <~ pageSignal
            }
        }
        
        func displayPage(_ page: Int) {
            pageObserver.send(value: page)
        }
    }
    
    var viewModel: ClipsViewModel!
    var controller: Controller!
    
    override func setUp() {
        super.setUp()
        viewModel = ClipsViewModel(provider: provider, persistentContainer: persistentContainer, pageSize: ClipsViewModelTests.pageSize)
        controller = Controller()
        controller.viewModel = viewModel
    }
    
    func testFetchesAndInsertsClips() {
        let changeSetObserver = TestObserver<ChangeSet, NoError>()
        viewModel.changeSets.observe(changeSetObserver.observer)
        controller.displayPage(0)
        expect(after: 0.01, by: 0.1, description: "Clips fetched and inserted", execute: {
            XCTAssertEqual(changeSetObserver.values.first?.insertions.count, ClipsViewModelTests.pageSize)
        })
        controller.displayPage(1)
        expect(after: 0.1, by: 1, description: "Second page fetched", execute: {
            XCTAssertEqual(changeSetObserver.values[1].insertions.count, ClipsViewModelTests.pageSize)
        })
    }
}
