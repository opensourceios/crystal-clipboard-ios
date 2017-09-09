//
//  ClipsDataProviderTests.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/31/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
import UIKit
import CoreData
import CellHelpers
@testable import CrystalClipboard

fileprivate let reuseIdentifier = "reuseIdentifier"

class ClipsDataProviderTests: CoreDataTestCase {
    class Controller: UITableViewController, DataSourceDelegate, FetchedResultsChangeSetProducerDelegate {
        func dataSource(_ dataSource: DataSource, reuseIdentifierForItem item: Any, atIndexPath indexPath: IndexPath) -> String {
            return reuseIdentifier
        }
        
        func configure(cell: ViewCell, fromDataSource dataSource: DataSource, atIndexPath indexPath: IndexPath, forItem item: Any) {
            guard let tableViewCell = cell as? UITableViewCell else { fatalError("Wrong cell type") }
            guard let clip = item as? ClipType else { fatalError("Wrong object type") }
            tableViewCell.textLabel?.text = clip.text
        }
        
        func fetchedResultsChangeSetProducer(_ fetchedResultsChangeSetProducer: FetchedResultsChangeSetProducer, didProduceChangeSet changeSet: ChangeSet) {
            tableView.performUpdates(fromChangeSet: changeSet)
        }
    }
    
    var controller: Controller!
    var dataSource: DataSource!
    var changeSetProducer: FetchedResultsChangeSetProducer!
    
    override func setUp() {
        super.setUp()
        
        controller = Controller()
        let clipsDataProvider = ClipsDataProvider(managedObjectContext: persistentContainer.viewContext)
        changeSetProducer = FetchedResultsChangeSetProducer()
        changeSetProducer.delegate = controller
        clipsDataProvider.fetchedResultsController.delegate = changeSetProducer
        dataSource = DataSource(dataProvider: clipsDataProvider, delegate: controller)
        controller.tableView.dataSource = dataSource
        controller.tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    override func tearDown() {
        controller = nil
        dataSource = nil
        super.tearDown()
    }
    
    func testDataProvided() {
        let context = persistentContainer.viewContext
        let user = User(id: generateNumber(), email: generateEmail())
        let clip1 = Clip(id: 1, text: generateString(), userID: user.id, createdAt: Date())
        let clip2 = Clip(id: 2, text: generateString(), userID: user.id, createdAt: Date())
        let clip3 = Clip(id: 3, text: generateString(), userID: user.id, createdAt: Date())
        ManagedClip(from: clip1, context: context)
        ManagedClip(from: clip2, context: context)
        try! context.save()
        let cell1 = dataSource.tableView(controller.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        let cell2 = dataSource.tableView(controller.tableView, cellForRowAt: IndexPath(row: 1, section: 0))
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 2)
        XCTAssertEqual(cell1.textLabel!.text!, clip2.text)
        XCTAssertEqual(cell2.textLabel!.text!, clip1.text)
        ManagedClip(from: clip3, context: context)
        try! context.save()
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 3)
    }
}
