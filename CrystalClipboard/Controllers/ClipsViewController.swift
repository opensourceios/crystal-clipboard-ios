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
import enum Result.NoError
import PKHUD
import CellHelpers

class ClipsViewController: UIViewController, PersistentContainerSettable, ProviderSettable {
    var persistentContainer: NSPersistentContainer!
    var provider: APIProvider!
    
    private lazy var viewModel: ClipsViewModel = ClipsViewModel(provider: self.provider, persistentContainer: self.persistentContainer, pageSize: ClipsViewController.pageSize)
    private var pageDisplayedObserver: Signal<Int, NoError>.Observer!
    private var lastPageDisplayed = 0
    @IBOutlet private weak var tableView: UITableView!
    
    private static let copiedHUDFlashDelay: TimeInterval = 0.5
    private static let pageSize = 25
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View model inputs
        
        let (pageDisplayedSignal, pageDisplayedObserver) = Signal<Int, NoError>.pipe()
        let pageWillAppear = reactive.trigger(for: #selector(UIViewController.viewWillAppear(_:)))
            .skip(first: 1)
            .map { [unowned self] in self.lastPageDisplayed }
        let pageWillEnterForeground = NotificationCenter.default.reactive
            .notifications(forName: .UIApplicationWillEnterForeground)
            .take(during: reactive.lifetime)
            .map { [unowned self] _ in self.lastPageDisplayed }
        
        viewModel.pageDisplayed <~ SignalProducer(values: pageDisplayedSignal.skipRepeats(), pageWillAppear, pageWillEnterForeground).flatten(.merge)
        self.pageDisplayedObserver = pageDisplayedObserver
        
        // View model outputs
        
        tableView.reactive.showNoClipsMessage <~ viewModel.showNoClipsMessage
        tableView.reactive.showLoadingFooter <~ viewModel.showLoadingFooter
        
        let scheduler = UIScheduler()
        
        viewModel.textToCopy.observe(on: scheduler).observeValues {
            UIPasteboard.general.string = $0
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            HUD.flash(.labeledSuccess(title: "clips.copied".localized, subtitle: $0), delay: ClipsViewController.copiedHUDFlashDelay)
        }
        
        viewModel.changeSets.observe(on: scheduler).observeValues { [unowned self] in self.tableView.performUpdates(fromChangeSet: $0) }
        
        tableView.dataSource = viewModel.dataSource
        tableView.delegate = self
    }
}

extension ClipsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        lastPageDisplayed = (indexPath.row + 1) / ClipsViewController.pageSize
        pageDisplayedObserver.send(value: lastPageDisplayed)
    }
}

fileprivate extension ClipsViewController {
    fileprivate static let noClipsView = NoClipsView.fromNib()!
    fileprivate static let loadingFooterView = LoadingFooterView.fromNib()!
    fileprivate static let spacingFooterView = SpacingFooterView.fromNib()!
}

fileprivate extension Reactive where Base: UITableView {
    fileprivate var showNoClipsMessage: BindingTarget<Bool> {
        return makeBindingTarget { $0.backgroundView = $1 ? ClipsViewController.noClipsView : nil }
    }
    
    fileprivate var showLoadingFooter: BindingTarget<Bool> {
        return makeBindingTarget { $0.tableFooterView = $1 ? ClipsViewController.loadingFooterView : ClipsViewController.spacingFooterView }
    }
}
