//
//  ClipsViewController.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/29/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit
import CoreData
import ReactiveSwift
import ReactiveCocoa

class ClipsViewController: UIViewController, PersistentContainerSettable, ProviderSettable {
    var persistentContainer: NSPersistentContainer!
    var provider: APIProvider!
    
    private lazy var viewModel: ClipsViewModel! = ClipsViewModel(provider: self.provider, persistentContainer: self.persistentContainer)
    
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View model inputs
        
        viewModel.setFetchedResultsControllerDelegate(tableView)
        
        // View model outputs
        
        tableView.dataSource = viewModel.dataSource
        viewModel.textToCopy.observe(on: UIScheduler()).observeValues { [unowned self] in self.presentAlert(message: $0) }
        
        // Other setup

        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        
        viewModel.fetchClips.apply().start()
    }
}
