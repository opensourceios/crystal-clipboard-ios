//
//  ClipsViewController.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/29/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import PKHUD

class ClipsViewController: ModeledViewController<ClipsViewModel>, UITableViewDelegate {
    private var pageScrolledTo = MutableProperty(0)
    @IBOutlet private weak var tableView: UITableView!
    
    private static let copiedHUDFlashDelay: TimeInterval = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View model inputs
        
        let pageWillAppear = reactive.trigger(for: #selector(UIViewController.viewWillAppear(_:)))
            .map { [unowned self] in self.pageScrolledTo.value }
        let pageWillEnterForeground = NotificationCenter.default.reactive
            .notifications(forName: .UIApplicationWillEnterForeground)
            .take(during: reactive.lifetime)
            .map { [unowned self] _ in self.pageScrolledTo.value }
        let pageWasScrolledTo = pageScrolledTo.signal.skip(first: 1).skipRepeats()
        
        viewModel.pageViewed <~ SignalProducer(values: pageWasScrolledTo, pageWillAppear, pageWillEnterForeground).flatten(.merge)
        
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
        
        viewModel.deleteAtIndexPath.errors.observeValues { [unowned self] _ in
            self.presentAlert(message: "clips.could-not-be-deleted".localized)
        }
        
        tableView.dataSource = viewModel.dataSource
        tableView.delegate = self
        tableView.tableHeaderView = ClipsViewController.spacingHeaderFooterView
        navigationController?.isToolbarHidden = false
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        pageScrolledTo.value = (indexPath.row + 1) / viewModel.pageSize
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "clips.delete".localized) { action, indexPath in
            self.viewModel.deleteAtIndexPath.apply(indexPath).start()
        }
        
        return [delete]
    }
}

fileprivate extension ClipsViewController {
    fileprivate static let noClipsView = NoClipsView.fromNib()!
    fileprivate static let loadingFooterView = LoadingFooterView.fromNib()!
    fileprivate static let spacingHeaderFooterView = SpacingHeaderFooterView.fromNib()!
}

fileprivate extension Reactive where Base: UITableView {
    fileprivate var showNoClipsMessage: BindingTarget<Bool> {
        return makeBindingTarget { $0.backgroundView = $1 ? ClipsViewController.noClipsView : nil }
    }
    
    fileprivate var showLoadingFooter: BindingTarget<Bool> {
        return makeBindingTarget { $0.tableFooterView = $1 ? ClipsViewController.loadingFooterView : ClipsViewController.spacingHeaderFooterView }
    }
}
