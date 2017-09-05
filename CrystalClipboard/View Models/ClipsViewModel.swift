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
    enum ClipsPresent {
        case none, all, some
    }
    
    // MARK: Inputs
    
    let viewAppearing = MutableProperty<Void>(())
    
    func setFetchedResultsControllerDelegate(_ delegate: NSFetchedResultsControllerDelegate) {
        dataProvider.fetchedResultsController.delegate = delegate
    }
    
    // MARK: Outputs
    
    private(set) lazy var dataSource: DataSource = DataSource(dataProvider: self.dataProvider, delegate: self)
    let textToCopy: Signal<String, NoError>
    let clipsPresent: Property<ClipsPresent>
    
    // MARK: Private
    
    private let dataProvider: ClipsDataProvider
    private let copyObserver: Signal<Signal<String, NoError>, NoError>.Observer
    private let token: Lifetime.Token
    
    // MARK: Initialization
    
    init(provider: APIProvider, persistentContainer: NSPersistentContainer) {
        let (lifetime, token) = Lifetime.make()
        self.token = token
        
        dataProvider = ClipsDataProvider(managedObjectContext: persistentContainer.viewContext)
        
        let (signal, observer) = Signal<Signal<String, NoError>, NoError>.pipe()
        textToCopy = signal.flatten(.merge)
        copyObserver = observer
        
        let allClipsFetched = MutableProperty(true)
        let initialClipCount = dataProvider.fetchedResultsController.fetchedObjects?.count ?? 0
        let clipCount = dataProvider.fetchedResultsController.reactive.producer(forKeyPath: "fetchedObjects")
            .take(during: lifetime)
            .map { ($0 as? [ManagedClip])?.count ?? 0 }
        let clipPresence: SignalProducer<ClipsViewModel.ClipsPresent, NoError> = clipCount
            .combineLatest(with: allClipsFetched.producer)
            .map {
                guard $0 > 0 else { return .none }
                return $1 ? .all : .some
        }
        clipsPresent = Property(initial: initialClipCount > 0 ? .all : .none, then: clipPresence)
        
        let fetchClips = Action<Int, [Clip], APIResponseError>() { page in
            provider.reactive.request(.listClips(page: page, pageSize: pageSize))
                .decode(to: [Clip].self)
                .on(value: { clips in
                    persistentContainer.performBackgroundTask { context in
                        context.mergePolicy = NSMergePolicy.rollback
                        for clip in clips { ManagedClip(from: clip, context: context) }
                        try? context.save()
                    }
                })
        }

        // Ignore viewAppearing's initial value
        viewAppearing.producer.skip(first: 1).startWithValues {
            fetchClips.apply(1).start()
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
        copyObserver.send(value: clipCellViewModel.copy.values)
        clipCell.setViewModel(clipCellViewModel)
    }
}
