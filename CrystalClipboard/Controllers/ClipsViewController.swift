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
    
    private lazy var viewModel: ClipsViewModel! = ClipsViewModel(provider: self.provider, persistentContainer: self.persistentContainer, pageSize: ClipsViewController.pageSize)
    @IBOutlet private weak var tableView: UITableView!
    fileprivate var pageDisplayedObserver: Signal<Int, NoError>.Observer!
    fileprivate var lastPageDisplayed = 0
    
    fileprivate static let noClipsView = NoClipsView.fromNib()!
    fileprivate static let loadingFooterView = LoadingFooterView.fromNib()!
    fileprivate static let spacingFooterView = SpacingFooterView.fromNib()!
    private static let copiedHUDFlashDelay: TimeInterval = 0.5
    private static let pageSize = 25
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let uiScheduler = UIScheduler()
        
        // View model inputs
        
        let pageWillAppear = reactive.trigger(for: #selector(UIViewController.viewWillAppear(_:)))
            .skip(first: 1)
            .map { [unowned self] in self.lastPageDisplayed }
        let pageWillEnterForeground = NotificationCenter.default.reactive
            .notifications(forName: .UIApplicationWillEnterForeground)
            .take(during: reactive.lifetime)
            .map { [unowned self] _ in self.lastPageDisplayed }
        let (pageDisplayedSignal, pageDisplayedObserver) = Signal<Int, NoError>.pipe()
        self.pageDisplayedObserver = pageDisplayedObserver
        viewModel.pageDisplayed <~ SignalProducer(values: pageDisplayedSignal.skipRepeats(), pageWillAppear, pageWillEnterForeground).flatten(.merge)
        
        // View model outputs
        
        viewModel.textToCopy.observe(on: UIScheduler()).observeValues {
            UIPasteboard.general.string = $0
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            HUD.flash(.labeledSuccess(title: "clips.copied".localized, subtitle: $0), delay: ClipsViewController.copiedHUDFlashDelay)
        }
        
        tableView.dataSource = viewModel.dataSource
        
        viewModel.changeSets.observe(on: uiScheduler).observeValues { [unowned self] in self.tableView.performUpdates(fromChangeSet: $0) }
        
        tableView.reactive.showNoClipsMessage <~ viewModel.showNoClipsMessage
        tableView.reactive.showLoadingFooter <~ viewModel.showLoadingFooter
        
        // Other setup
        
        tableView.delegate = self
    }
}

extension ClipsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        lastPageDisplayed = (indexPath.row + 1) / ClipsViewController.pageSize
        pageDisplayedObserver.send(value: lastPageDisplayed)
    }
}

fileprivate extension Reactive where Base: UITableView {
    fileprivate var showNoClipsMessage: BindingTarget<Bool> {
        return makeBindingTarget { $0.backgroundView = $1 ? ClipsViewController.noClipsView : nil }
    }
    
    fileprivate var showLoadingFooter: BindingTarget<Bool> {
        return makeBindingTarget { $0.tableFooterView = $1 ? ClipsViewController.loadingFooterView : ClipsViewController.spacingFooterView }
    }
}
