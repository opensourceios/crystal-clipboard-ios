//
//  LandingViewController.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/21/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController, ProviderSettable {
    var provider: APIProvider!

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination as? ProviderSettable)?.provider = provider
    }
}
