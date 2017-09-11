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
import struct Result.AnyError
import CellHelpers

typealias ClipDisplayError = AnyError

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
    private let cable = Cable(url: Constants.environment.cableURL,
                              origin: Constants.environment.baseURL.absoluteString,
                              token: User.current?.authToken?.token)
    private var connection: Cable.Connection?
    private var channel: Channel?
    private var channelReconnectInterval: Int = 0
    private static var maxCableReconnectTries = 10
    
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
                .mapError { ClipDisplayError($0) }
                .attemptMap {
                    let deletionPredicate = ClipsViewModel.clipDeletionPredicate(clipIDs: $0.map { $0.id },
                                                                                     maxID: maxID,
                                                                                     maxFetchedClipID: &maxFetchedClipID)
                    try ClipsViewModel.persistClips($0,
                                                    inPersistentContainer: persistentContainer,
                                                    deletionPredicate: deletionPredicate)
            }
        }
        showLoadingFooter = pageViewed.isExecuting
        
        super.init()
        
        connect(cable: cable, persistentContainer: persistentContainer)
        
        fetchedResultsChangeSetProducer.delegate = self
        fetchedResultsChangeSetProducer.forwardingDelegate = self
    }
    
    private func connect(cable: Cable, persistentContainer: NSPersistentContainer) {
        connection = cable.connect().on(
            failed: { [unowned self] _ in
                guard self.channelReconnectInterval < ClipsViewModel.maxCableReconnectTries else { return }
                self.channelReconnectInterval += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(self.channelReconnectInterval)) {
                    self.connect(cable: self.cable, persistentContainer: persistentContainer)
                }
        },
            value: { [unowned self] value in
                switch value {
                case .connected:
                    self.channelReconnectInterval = 0
                    self.channel = self.cable.subscribe(channelIdentifier: Constants.clipboardChannelIdentifier).on(value: {
                        guard
                            case let .message(message) = $0,
                            let dictionary = message as? [String: Any],
                            let clipChannelMessage = ClipChannelMessage(dictionary: dictionary)
                            else { return }
                        let clips: [Clip]
                        let deletionPredicate: NSPredicate?
                        switch clipChannelMessage {
                        case let .clipCreated(clip):
                            clips = [clip]
                            deletionPredicate = nil
                        case let .clipDeleted(id):
                            clips = []
                            deletionPredicate = NSPredicate(format: "%K = %i", #keyPath(ManagedClip.id), id)
                        }
                        try? ClipsViewModel.persistClips(clips, inPersistentContainer: persistentContainer, deletionPredicate: deletionPredicate)
                    })
                default: break
                }
        })
    }
}

private extension ClipsViewModel {
    // this is separated out to keep init from being too long
    private static func persistClips(_ clips: [Clip],
                                     inPersistentContainer persistentContainer: NSPersistentContainer,
                                     deletionPredicate: NSPredicate?) throws {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.rollback
        for clip in clips {
            ManagedClip(from: clip, context: context)
        }
        if let deletionPredicate = deletionPredicate {
            let deletionFetchRequest = ManagedClip.fetchRequest() as! NSFetchRequest<ManagedClip>
            deletionFetchRequest.predicate = deletionPredicate
            for clip in try context.fetch(deletionFetchRequest) {
                context.delete(clip)
            }
        }
        try context.save()
    }
    
    private static func clipDeletionPredicate(clipIDs: [Int], maxID: Int?, maxFetchedClipID: inout Int?) -> NSPredicate? {
        let previousMaxFetchedClipID = maxFetchedClipID
        maxFetchedClipID = clipIDs.last ?? maxFetchedClipID
        if let firstID = clipIDs.first, let lastID = clipIDs.last {
            let idKeyPath = #keyPath(ManagedClip.id)
            let predicateFormat = "%K < %i AND %K > %i AND NOT (%K IN %@)"
            let predicateArguments: [Any] = [idKeyPath, firstID, idKeyPath, lastID, idKeyPath, clipIDs, idKeyPath]
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
            return predicate
        }
        
        return nil
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
