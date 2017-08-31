//
//  ProviderSettable.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/30/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

protocol ProviderSettable: class {
    var provider: APIProvider! { get set }
}
