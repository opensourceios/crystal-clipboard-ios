//
//  ClipsViewController.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/29/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit
import CoreData
import CellHelpers

class ClipsViewController: UIViewController, PersistentContainerSettable, ProviderSettable {
    var persistentContainer: NSPersistentContainer!
    var provider: APIProvider!
    
    private lazy var viewModel: ClipsViewModel! = ClipsViewModel(provider: self.provider, persistentContainer: self.persistentContainer)
    private var dataSource: DataSource!
    
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Other setup
        
        let dataProvider = ClipsDataProvider(managedObjectContext: self.persistentContainer.viewContext)
        dataProvider.fetchedResultsController.delegate = tableView
        dataSource = DataSource(dataProvider: dataProvider, delegate: self)
        tableView.dataSource = dataSource
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        
        viewModel.fetchClips.apply().start()
    }
}

extension ClipsViewController: DataSourceDelegate {
    func dataSource(_ dataSource: DataSource, reuseIdentifierForObject object: AnyObject, atIndexPath indexPath: IndexPath) -> String {
        return TableViewCellReuseIdentifier.ClipTableViewCell.rawValue
    }
    
    func configureCell(_ cell: ViewCell, fromDataSource dataSource: DataSource, atIndexPath indexPath: IndexPath, forObject object: AnyObject) {
        guard let clipCell = cell as? ClipTableViewCell else { fatalError("Wrong cell type") }
        guard let clip = object as? ClipType else { fatalError("Wrong object type") }
        clipCell.viewModel = ClipCellViewModel(clip: clip)
    }
}
