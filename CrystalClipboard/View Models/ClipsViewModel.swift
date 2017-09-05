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
    
    let viewAppearing = MutableProperty<Void>(())
    
    func setFetchedResultsControllerDelegate(_ delegate: NSFetchedResultsControllerDelegate) {
        dataProvider.fetchedResultsController.delegate = delegate
    }
    
    // MARK: Outputs
    
    private(set) lazy var dataSource: DataSource = ClipsDataSource(dataProvider: self.dataProvider, delegate: self)
    let textToCopy: Signal<String, NoError>
    let showLoadingFooter: Property<Bool>
    
    // MARK: Private
    
    private let dataProvider: ClipsDataProvider
    private let copyObserver: Signal<Signal<String, NoError>, NoError>.Observer
    
    // MARK: Initialization
    
    init(provider: APIProvider, persistentContainer: NSPersistentContainer) {
        let dataProvider = ClipsDataProvider(managedObjectContext: persistentContainer.viewContext)
        self.dataProvider = dataProvider
        
        let (signal, observer) = Signal<Signal<String, NoError>, NoError>.pipe()
        textToCopy = signal.flatten(.merge)
        copyObserver = observer
        
        let moreClipsAvailaible = MutableProperty(false)
        showLoadingFooter = Property(initial: moreClipsAvailaible.value, then: moreClipsAvailaible.signal)
        
        let fetchClips = Action<Int, ([Clip], APIResponse<[Clip]>.PageInfo), APIResponseError>() {
            provider.reactive.request(.listClips(page: $0, pageSize: pageSize)).decodeWithPageInfo(to: [Clip].self)
        }
        
        fetchClips.values.observeValues { clips, pageInfo in
            persistentContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergePolicy.rollback
                for clip in clips { ManagedClip(from: clip, context: context) }
                try? context.save()
            }
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
