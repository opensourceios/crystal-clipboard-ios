//
//  RootViewController.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/21/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    @IBOutlet private weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let landingViewController = UIStoryboard.main.instantiateViewController(withIdentifier: .Landing)
        let navigationController = UINavigationController(rootViewController: landingViewController)
        addChildViewController(navigationController)
        navigationController.view.frame = containerView.bounds
        view.addSubview(navigationController.view)
        navigationController.didMove(toParentViewController: self)
    }
}
