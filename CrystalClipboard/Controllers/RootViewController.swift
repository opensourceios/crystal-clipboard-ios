//
//  RootViewController.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/21/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit
import CoreData
import ReactiveSwift

private let transitionDuration: TimeInterval = 0.5

class RootViewController: UIViewController, PersistentContainerSettable {
    var persistentContainer: NSPersistentContainer!
    
    private let viewModel = RootViewModel()
    fileprivate var currentController: UIViewController! {
        didSet {
            (currentController.childViewControllers.first as? PersistentContainerSettable)?.persistentContainer = persistentContainer
        }
    }
    
    @IBOutlet fileprivate weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let transition = viewModel.transitionTo.value
        let storyboard = UIStoryboard(name: transition.storyboardName)
        let controller = storyboard.instantiateViewController(withIdentifier: transition.controllerIdentifier)
        (controller as? ProviderSettable)?.provider = transition.provider
        let navigationController = wrappingNavigation(forController: controller)
        addChildViewController(navigationController)
        view.addSubview(navigationController.view)
        navigationController.didMove(toParentViewController: self)
        currentController = navigationController
        
        viewModel.transitionTo.signal.observe(on: UIScheduler()).observeValues { [unowned self] in
            let viewController = UIStoryboard(name: $0.storyboardName).instantiateViewController(withIdentifier: $0.controllerIdentifier)
            (viewController as? ProviderSettable)?.provider = $0.provider
            let navigationController = self.wrappingNavigation(forController: viewController)
            self.performTransition(fromViewController: self.currentController, toViewController: navigationController)
        }
    }
}

fileprivate extension RootViewController {
    func wrappingNavigation(forController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: forController)
        navigationController.view.frame = containerView.bounds
        return navigationController
    }
    
    func performTransition(fromViewController: UIViewController, toViewController: UIViewController) {
        self.currentController = toViewController
        fromViewController.willMove(toParentViewController: nil)
        addChildViewController(toViewController)
        transition(from: fromViewController,
                   to: toViewController,
                   duration: transitionDuration,
                   options: .transitionCrossDissolve,
                   animations: nil) { _ in
            fromViewController.removeFromParentViewController()
            toViewController.didMove(toParentViewController: self)
        }
    }
}
