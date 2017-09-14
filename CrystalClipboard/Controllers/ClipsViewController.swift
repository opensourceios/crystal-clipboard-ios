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
import struct CellHelpers.ChangeSet
import PKHUD

class ClipsViewController: ModeledViewController<ClipsViewModel>, UITableViewDelegate {
    
    // MARK: Private stored properties
    
    private var pageScrolledTo = MutableProperty(0)
    
    // MARK: IBOutlet private stored properties
    
    @IBOutlet
    private weak var tableView: UITableView!
    
    // MARK: UIViewController internal overridden methods
    
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
        tableView.reactive.changeSets <~ viewModel.changeSets
        tableView.dataSource = viewModel.dataSource
        reactive.textToCopy <~ viewModel.textToCopy
        reactive.alertMessage <~ viewModel.deleteAtIndexPath.errors.map { _ in "clips.could-not-be-deleted".localized }
        
        // Other setup
        
        tableView.delegate = self
        tableView.tableHeaderView = ClipsViewController.spacingHeaderFooterView
    }
    
    // MARK: UITableViewDelegate internal methods
    
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
    
    // MARK: Fileprivate constants
    
    fileprivate static let noClipsView = NoClipsView.fromNib()!
    fileprivate static let loadingFooterView = LoadingFooterView.fromNib()!
    fileprivate static let spacingHeaderFooterView = SpacingHeaderFooterView.fromNib()!
    fileprivate static let copiedHUDFlashDelay: TimeInterval = 0.5
}

fileprivate extension Reactive where Base: UITableView {
    
    // MARK: UITableView fileprivate reactive extensions
    
    fileprivate var showNoClipsMessage: BindingTarget<Bool> {
        return makeBindingTarget { $0.backgroundView = $1 ? ClipsViewController.noClipsView : nil }
    }
    
    fileprivate var showLoadingFooter: BindingTarget<Bool> {
        return makeBindingTarget { $0.tableFooterView = $1 ? ClipsViewController.loadingFooterView : ClipsViewController.spacingHeaderFooterView }
    }
    
    fileprivate var changeSets: BindingTarget<ChangeSet> {
        return makeBindingTarget { $0.performUpdates(fromChangeSet: $1) }
    }
}

fileprivate extension Reactive where Base: ClipsViewController {
    
    // MARK: Fileprivate reactive extensions
    
    fileprivate var textToCopy: BindingTarget<String> {
        return makeBindingTarget { _, text in
            UIPasteboard.general.string = text
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            HUD.flash(.labeledSuccess(title: "clips.copied".localized, subtitle: text), delay: ClipsViewController.copiedHUDFlashDelay)
        }
    }
}
