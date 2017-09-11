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
    
    let pageViewed: Action<Int, Void, ClipDisplayError>
    
    // MARK: Outputs
    
    let pageSize: Int
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
    
    // MARK: Initialization
    
    init(provider: APIProvider, persistentContainer: NSPersistentContainer, pageSize: Int) {
        self.pageSize = pageSize
        
        let dataProvider = ClipsDataProvider(managedObjectContext: persistentContainer.viewContext)
        self.dataProvider = dataProvider
        fetchedResultsChangeSetProducer = FetchedResultsChangeSetProducer()
        dataProvider.fetchedResultsController.delegate = fetchedResultsChangeSetProducer
        
        (changeSets, changeSetsObserver) = Signal<ChangeSet, NoError>.pipe()
        
        let textToCopySignals = Signal<Signal<String, NoError>, NoError>.pipe()
        textToCopy = textToCopySignals.output.flatten(.merge)
        copyObserver = textToCopySignals.input
        
        clipCount = MutableProperty(dataProvider.fetchedResultsController.fetchedObjects!.count)
        showNoClipsMessage = Property(initial: clipCount.value == 0, then: clipCount.signal.map { $0 == 0 })
        
        var maxFetchedClipID: Int?
        
        pageViewed = Action() { page in
            let presentClips = dataProvider.fetchedResultsController.fetchedObjects!
            let clipWithMaxIDIndex = page * pageSize - 1
            let maxID = clipWithMaxIDIndex > 0 ? presentClips[clipWithMaxIDIndex].id : nil
            return provider.reactive.request(.listClips(maxID: maxID, count: pageSize))
                .decode(to: [Clip].self)
                .mapError { ClipDisplayError.response(underlying: $0) }
                .map { ClipsViewModel.persistClips($0,
                                                   inPersistentContainer: persistentContainer,
                                                   maxID: maxID,
                                                   maxFetchedClipID: &maxFetchedClipID)
                }
                .mapError { ClipDisplayError.persistence(underlying: $0) }
                .map { _ in () }
        }
        showLoadingFooter = pageViewed.isExecuting
        
        super.init()
        
        fetchedResultsChangeSetProducer.delegate = self
        fetchedResultsChangeSetProducer.forwardingDelegate = self
    }
}

private extension ClipsViewModel {
    // this is separated out to keep init from being too long
    private static func persistClips(_ clips: [Clip],
                                     inPersistentContainer persistentContainer: NSPersistentContainer,
                                     maxID: Int?,
                                     maxFetchedClipID: inout Int?) {
        let previousMaxFetchedClipID = maxFetchedClipID
        maxFetchedClipID = clips.last?.id ?? maxFetchedClipID
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.rollback
        for clip in clips { ManagedClip(from: clip, context: context) }
        let fetchedClipIDs = clips.map { $0.id }
        if let firstID = fetchedClipIDs.first, let lastID = fetchedClipIDs.last {
            let idKeyPath = #keyPath(ManagedClip.id)
            let predicateFormat = "%K < %i AND %K > %i AND NOT (%K IN %@)"
            let predicateArguments: [Any] = [idKeyPath, firstID, idKeyPath, lastID, idKeyPath, fetchedClipIDs, idKeyPath]
            var predicate = NSPredicate(format: predicateFormat, argumentArray: predicateArguments)
            if maxID == nil {
                let orPredicateFormat = "%K > %i"
                let orPredicateArguments: [Any] = [idKeyPath, firstID]
                let orPredicate = NSPredicate(format: orPredicateFormat, argumentArray: orPredicateArguments)
                predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate, orPredicate])
            } else if let previousMaxFetchedClipID = previousMaxFetchedClipID {
                let orPredicateFormat = "%K < %i AND %K > %i"
                let orPredicateArguments: [Any] = [idKeyPath, previousMaxFetchedClipID, idKeyPath, firstID]
                let orPredicate = NSPredicate(format: orPredicateFormat, argumentArray: orPredicateArguments)
                predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate, orPredicate])
            }
            let clipsToDeleteFetchRequest = ManagedClip.fetchRequest() as! NSFetchRequest<ManagedClip>
            clipsToDeleteFetchRequest.predicate = predicate
            if let clipsToDelete = try? context.fetch(clipsToDeleteFetchRequest) {
                for clip in clipsToDelete { context.delete(clip) }
            }
        }
        try? context.save()
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
