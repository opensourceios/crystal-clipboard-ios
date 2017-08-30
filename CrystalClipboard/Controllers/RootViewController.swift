//
//  RootViewController.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/21/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    private let viewModel = RootViewModel()
    fileprivate var currentController: UIViewController!
    
    @IBOutlet fileprivate weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: viewModel.transitionTo.value.storyboardName)
        let controller = storyboard.instantiateViewController(withIdentifier: viewModel.transitionTo.value.controllerIdentifier)
        let navigationController = wrappingNavigation(forController: controller)
        addChildViewController(navigationController)
        view.addSubview(navigationController.view)
        navigationController.didMove(toParentViewController: self)
        currentController = navigationController
        
        viewModel.transitionTo.signal.observeValues { [unowned self] in
            let viewController = UIStoryboard(name: $0.storyboardName).instantiateViewController(withIdentifier: $0.controllerIdentifier)
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
        fromViewController.willMove(toParentViewController: nil)
        addChildViewController(toViewController)
        transition(from: fromViewController, to: toViewController, duration: 0.5, options: .transitionCrossDissolve, animations: nil) { _ in
            fromViewController.removeFromParentViewController()
            toViewController.didMove(toParentViewController: self)
            self.currentController = toViewController
        }
    }
}
