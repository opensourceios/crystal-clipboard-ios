//
//  ClipsViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/30/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import CoreData
import ReactiveSwift
import enum Result.NoError
import CellHelpers

class ClipsViewModel: NSObject {
    // MARK: Inputs
    
    let viewAppearing = MutableProperty<Void>(())
    
    // MARK: Outputs
    
    private(set) lazy var dataSource: DataSource = DataSource(dataProvider: self.dataProvider, delegate: self)
    let changeSets: Signal<ChangeSet, NoError>
    let textToCopy: Signal<String, NoError>
    let showNoClipsMessage: Property<Bool>
    let showLoadingFooter: Property<Bool>
    
    // MARK: Private
    
    private let dataProvider: ClipsDataProvider
    private let copyObserver: Signal<Signal<String, NoError>, NoError>.Observer
    private let fetchedResultsChangeSetProducer: FetchedResultsChangeSetProducer
    private let changeSetsObserver: Signal<ChangeSet, NoError>.Observer
    private let clipCount: MutableProperty<Int>
    private static let pageSize = 25
    
    // MARK: Initialization
    
    init(provider: APIProvider, persistentContainer: NSPersistentContainer) {
        let dataProvider = ClipsDataProvider(managedObjectContext: persistentContainer.viewContext)
        self.dataProvider = dataProvider
        fetchedResultsChangeSetProducer = FetchedResultsChangeSetProducer()
        dataProvider.fetchedResultsController.delegate = fetchedResultsChangeSetProducer
        
        let (changeSets, changeSetsObserver) = Signal<ChangeSet, NoError>.pipe()
        self.changeSets = changeSets
        self.changeSetsObserver = changeSetsObserver
        
        let (textToCopy, copyObserver) = Signal<Signal<String, NoError>, NoError>.pipe()
        self.textToCopy = textToCopy.flatten(.merge)
        self.copyObserver = copyObserver
        
        clipCount = MutableProperty(dataProvider.fetchedResultsController.fetchedObjects!.count)
        showNoClipsMessage = Property(initial: clipCount.value == 0, then: clipCount.signal.map { $0 == 0 })
        
        let fetchClips = Action<(maxID: Int?, sinceID: Int?), [Clip], ResponseError>() {
            provider.reactive.request(.listClips(maxID: $0, sinceID: $1, count: ClipsViewModel.pageSize)).decode(to: [Clip].self)
        }
        showLoadingFooter = fetchClips.isExecuting
        
        fetchClips.values.observeValues { clips in
            persistentContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergePolicy.rollback
                for clip in clips { ManagedClip(from: clip, context: context) }
                try? context.save()
            }
        }

        // Ignore viewAppearing's initial value
        viewAppearing.producer.skip(first: 1).startWithValues {
            fetchClips.apply((maxID: nil, sinceID: nil)).start()
        }
        
        super.init()
        
        fetchedResultsChangeSetProducer.delegate = self
        fetchedResultsChangeSetProducer.forwardingDelegate = self
    }
}

extension ClipsViewModel: FetchedResultsChangeSetProducerDelegate {
    func fetchedResultsChangeSetProducer(_ fetchedResultsChangeSetProducer: FetchedResultsChangeSetProducer, didProduceChangeSet changeSet: ChangeSet) {
        changeSetsObserver.send(value: changeSet)
    }
}

extension ClipsViewModel: FetchedResultsChangeSetProducerForwardingDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        clipCount.value = controller.fetchedObjects!.count
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
