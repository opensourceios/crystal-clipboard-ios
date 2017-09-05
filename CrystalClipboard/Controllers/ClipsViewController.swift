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
import PKHUD
import CellHelpers

class ClipsViewController: UIViewController, PersistentContainerSettable, ProviderSettable {
    var persistentContainer: NSPersistentContainer!
    var provider: APIProvider!
    
    private lazy var viewModel: ClipsViewModel! = ClipsViewModel(provider: self.provider, persistentContainer: self.persistentContainer)
    @IBOutlet private weak var tableView: UITableView!
    private let loadingFooterView = LoadingFooterView.fromNib()!
    private let spacingFooterView = SpacingFooterView.fromNib()!
    private let noClipsView = NoClipsView.fromNib()!
    private static let copiedHUDFlashDelay: TimeInterval = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let uiScheduler = UIScheduler()
        
        // View model inputs
        
        let willEnterForeground = NotificationCenter.default.reactive.notifications(forName: .UIApplicationWillEnterForeground).take(during: reactive.lifetime).map { _ in Void() }
        let viewWillAppear = reactive.trigger(for: #selector(UIViewController.viewWillAppear(_:)))
        viewModel.viewAppearing <~ SignalProducer(values: willEnterForeground, viewWillAppear).flatten(.merge)
        
        // View model outputs
        
        viewModel.textToCopy.observe(on: UIScheduler()).observeValues {
            UIPasteboard.general.string = $0
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            HUD.flash(.labeledSuccess(title: "clips.copied".localized, subtitle: $0), delay: ClipsViewController.copiedHUDFlashDelay)
        }
        
        tableView.dataSource = viewModel.dataSource
        
        viewModel.changeSets.observe(on: uiScheduler).observeValues { [unowned self] in
            self.tableView.performUpdates(fromChangeSet: $0)
        }
        
        tableView.backgroundView = viewModel.showNoClipsMessage.value ? noClipsView : nil
        viewModel.showNoClipsMessage.signal.observe(on: uiScheduler).observeValues { [unowned self] in
            self.tableView.backgroundView = $0 ? self.noClipsView : nil
        }
        
        tableView.tableFooterView = viewModel.showLoadingFooter.value ? loadingFooterView : spacingFooterView
        viewModel.showLoadingFooter.signal.observe(on: uiScheduler).observeValues { [unowned self] in
            self.tableView.tableFooterView = $0 ? self.loadingFooterView : self.spacingFooterView
        }
    }
}
