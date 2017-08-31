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
    class Controller: UITableViewController, DataSourceDelegate {
        func dataSource(_ dataSource: DataSource, reuseIdentifierForObject object: AnyObject, atIndexPath indexPath: IndexPath) -> String {
            return reuseIdentifier
        }
        func configureCell(_ cell: ViewCell, fromDataSource dataSource: DataSource, atIndexPath indexPath: IndexPath, forObject object: AnyObject) {
            guard let tableViewCell = cell as? UITableViewCell else { fatalError("Wrong cell type") }
            guard let managedClip = object as? ManagedClip else { fatalError("Wrong object type") }
            tableViewCell.textLabel?.text = managedClip.text
        }
    }
    
    var controller: Controller!
    var dataSource: FetchedDataSource!
    
    override func setUp() {
        super.setUp()
        
        controller = Controller()
        let clipsDataProvider = ClipsDataProvider(managedObjectContext: persistentContainer.viewContext)
        dataSource = FetchedDataSource(dataProvider: clipsDataProvider, delegate: controller, view: controller.tableView)
        controller.tableView.dataSource = dataSource
        controller.tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    override func tearDown() {
        controller = nil
        dataSource = nil
        super.tearDown()
    }
    
    func testDataProvided() {
        let clip1 = Clip(id: 1, text: "hi", createdAt: Date())
        let clip2 = Clip(id: 2, text: "bye", createdAt: Date())
        ManagedClip(from: clip1, context: persistentContainer.viewContext)
        ManagedClip(from: clip2, context: persistentContainer.viewContext)
        try! persistentContainer.viewContext.save()
        let cell1 = dataSource.tableView(controller.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        let cell2 = dataSource.tableView(controller.tableView, cellForRowAt: IndexPath(row: 1, section: 0))
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 2)
        XCTAssertEqual(cell1.textLabel!.text!, clip2.text)
        XCTAssertEqual(cell2.textLabel!.text!, clip1.text)
    }
}
