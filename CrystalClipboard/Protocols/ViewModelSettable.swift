//
//  ViewModelSettable.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/11/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

protocol ViewModelSettable: _ViewModelSettable {
    associatedtype ViewModel: ViewModelType
    var viewModel: ViewModel! { get set }
}

extension ViewModelSettable {
    var _viewModel: ViewModelType! {
        set {
           guard let viewModel = newValue as? ViewModel else { fatalError("Wrong view model type") }
            self.viewModel = viewModel
        }
        get {
            return viewModel
        }
    }
    
    var viewModelType: ViewModelType.Type {
        return ViewModel.self
    }
}
