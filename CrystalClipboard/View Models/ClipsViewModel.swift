//
//  ClipsViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/30/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import CoreData
import ReactiveSwift
import Result
import Moya
import CellHelpers

fileprivate let pageSize = 25

class ClipsViewModel {
    
    // MARK: Inputs
    
    private(set) lazy var fetchClips: Action<Void, [Clip], APIResponseError> = Action() { _ in
        return self.provider.reactive.request(.listClips(page: 1, pageSize: pageSize)).decode(to: [Clip].self)
    }
    
    func setFetchedResultsControllerDelegate(_ delegate: NSFetchedResultsControllerDelegate) {
        dataProvider.fetchedResultsController.delegate = delegate
    }
    
    // MARK: Outputs
    
    private(set) lazy var dataSource: DataSource = DataSource(dataProvider: self.dataProvider, delegate: self)
    let textToCopy: Signal<String, NoError>
    
    // MARK: Private
    
    private let provider: APIProvider
    private let persistentContainer: NSPersistentContainer
    private let dataProvider: ClipsDataProvider
    private let copyObserver: Signal<Signal<String, NoError>, NoError>.Observer
    
    // MARK: Initialization
    
    init(provider: APIProvider, persistentContainer: NSPersistentContainer) {
        self.provider = provider
        self.persistentContainer = persistentContainer
        dataProvider = ClipsDataProvider(managedObjectContext: self.persistentContainer.viewContext)
        let (signal, observer) = Signal<Signal<String, NoError>, NoError>.pipe()
        textToCopy = signal.flatten(.merge)
        copyObserver = observer

        fetchClips.values.observeValues { clips in
            persistentContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergePolicy.rollback
                for clip in clips {
                    ManagedClip(from: clip, context: context)
                }
                try? context.save()
            }
        }
    }
}

extension ClipsViewModel: DataSourceDelegate {
    func dataSource(_ dataSource: DataSource, reuseIdentifierForItem item: Any, atIndexPath indexPath: IndexPath) -> String {
        return TableViewCellReuseIdentifier.ClipTableViewCell.rawValue
    }
    
    func configure(cell: ViewCell, fromDataSource dataSource: DataSource, atIndexPath indexPath: IndexPath, forItem item: Any) {
        guard let clipCell = cell as? ClipCellViewModelSettable else { fatalError("Wrong cell type") }
        guard let clip = item as? ClipType else { fatalError("Wrong object type") }
        let clipCellViewModel = ClipCellViewModel(clip: clip)
        copyObserver.send(value: clipCellViewModel.copy.values.take(during: clipCellViewModel.lifetime))
        clipCell.setViewModel(clipCellViewModel)
    }
}
