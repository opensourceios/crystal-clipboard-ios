//
//  RootViewController.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/21/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit
import ReactiveSwift

private let transitionDuration: TimeInterval = 0.5

class RootViewController: ModeledViewController<RootViewModel> {
    private let rootViewModel = RootViewModel()
    override var viewModel: RootViewModel! {
        get { return rootViewModel }
        set {}
    }
    fileprivate var currentController: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let transition = viewModel.transitionTo.value
        let storyboard = UIStoryboard(name: transition.storyboardName)
        let controller = storyboard.instantiateViewController(withIdentifier: transition.controllerIdentifier)
        if var modeledViewcontroller = controller as? _ViewModelSettable {
            modeledViewcontroller._viewModel = transition.viewModel
        }
        let navigationController = wrappingNavigation(forController: controller)
        addChildViewController(navigationController)
        view.addSubview(navigationController.view)
        navigationController.didMove(toParentViewController: self)
        currentController = navigationController
        
        viewModel.transitionTo.signal.observe(on: UIScheduler()).observeValues { [unowned self] in
            let viewController = UIStoryboard(name: $0.storyboardName).instantiateViewController(withIdentifier: $0.controllerIdentifier)
            if var modeledViewcontroller = viewController as? _ViewModelSettable {
                modeledViewcontroller._viewModel = $0.viewModel
            }
            let navigationController = self.wrappingNavigation(forController: viewController)
            self.performTransition(fromViewController: self.currentController, toViewController: navigationController)
        }
    }
}

fileprivate extension RootViewController {
    func wrappingNavigation(forController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: forController)
        navigationController.view.frame = view.bounds
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
