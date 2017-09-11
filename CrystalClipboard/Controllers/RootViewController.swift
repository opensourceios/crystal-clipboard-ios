//
//  RootViewController.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/21/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit
import ReactiveSwift

class RootViewController: UIViewController {
    private let viewModel = RootViewModel()
    fileprivate var currentViewController: UIViewController!
    
    private static let transitionDuration: TimeInterval = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let initialViewController = viewControllerForTransition(viewModel.transitionTo.value)
        performTransition(fromViewController: nil, toViewController: initialViewController)
        
        reactive.transition <~ viewModel.transitionTo
    }
}

fileprivate extension RootViewController {
    fileprivate func viewControllerForTransition(_ transition: TransitionType) -> UIViewController {
        let storyboard = UIStoryboard(name: transition.storyboardName)
        let controller = storyboard.instantiateViewController(withIdentifier: transition.controllerIdentifier)
        if var modeledViewController = controller as? _ViewModelSettable {
            modeledViewController._viewModel = transition.viewModel
        }
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.view.frame = view.bounds
        
        return navigationController
    }
    
    fileprivate func performTransition(fromViewController: UIViewController?, toViewController: UIViewController) {
        currentViewController = toViewController
        fromViewController?.willMove(toParentViewController: nil)
        addChildViewController(toViewController)
        if let fromViewController = fromViewController {
            transition(from: fromViewController,
                       to: toViewController,
                       duration: RootViewController.transitionDuration,
                       options: .transitionCrossDissolve,
                       animations: nil) { _ in
                        fromViewController.removeFromParentViewController()
                        toViewController.didMove(toParentViewController: self)
            }
        } else {
            view.addSubview(toViewController.view)
            toViewController.didMove(toParentViewController: self)
        }
    }
}

fileprivate extension Reactive where Base: RootViewController {
    fileprivate var transition: BindingTarget<TransitionType> {
        return makeBindingTarget {
            let toViewController = $0.viewControllerForTransition($1)
            $0.performTransition(fromViewController: $0.currentViewController, toViewController: toViewController)
        }
    }
}
