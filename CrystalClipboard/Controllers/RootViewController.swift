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
    
    @IBOutlet fileprivate weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: viewModel.initialStoryboardName.value)
        let controller = storyboard.instantiateViewController(withIdentifier: viewModel.initialViewControllerIdentifier.value)
        display(controller: controller)
    }
}

fileprivate extension RootViewController {
    func display(controller: UIViewController) {
        let navigationController = UINavigationController(rootViewController: controller)
        addChildViewController(navigationController)
        navigationController.view.frame = containerView.bounds
        view.addSubview(navigationController.view)
        navigationController.didMove(toParentViewController: self)
    }
}
