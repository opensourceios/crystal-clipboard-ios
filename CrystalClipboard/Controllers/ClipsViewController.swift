//
//  ClipsViewController.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/29/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit
import CoreData

class ClipsViewController: UIViewController, ManagedObjectContextSettable, ProviderSettable {
    var managedObjectContext: NSManagedObjectContext!
    var provider: APIProvider!
    
    private lazy var viewModel: ClipsViewModel! = ClipsViewModel(provider: self.provider)
    
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
