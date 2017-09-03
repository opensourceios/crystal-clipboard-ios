//
//  RootViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/29/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import ReactiveSwift
import Result

protocol TransitionType {
    var storyboardName: StoryboardNames { get }
    var controllerIdentifier: ViewControllerStoryboardIdentifier { get }
    var provider: APIProvider { get }
}

fileprivate enum Transition: TransitionType {
    case signIn, signOut
    var storyboardName: StoryboardNames {
        switch self {
        case .signIn: return .Main
        case .signOut: return .SignedOut
        }
    }
    
    var controllerIdentifier: ViewControllerStoryboardIdentifier {
        switch self {
        case .signIn: return .Clips
        case .signOut: return .Landing
        }
    }
    
    var provider: APIProvider {
        switch self {
        case .signIn:
            guard let userProvider = APIProvider.userProvider() else { fatalError("Should not transition to signed in without credentials") }
            return userProvider
        case .signOut: return APIProvider.adminProvider()
        }
    }
}

class RootViewModel {
    // MARK: Outputs
    
    let transitionTo: Property<TransitionType>
    
    // MARK: Private
    
    private let (lifetime, token) = Lifetime.make()
    
    // MARK: Initialization
    
    init() {
        let notificationCenter = NotificationCenter.default.reactive
        let signInSignal = notificationCenter.notifications(forName: .userSignedIn).take(during: lifetime)
        let signOutSignal = notificationCenter.notifications(forName: .userSignedOut).take(during: lifetime)
        let notificationsSignal = SignalProducer(values: signInSignal, signOutSignal).flatten(.merge)
        let then = notificationsSignal.map { notification -> TransitionType in
            switch notification.name {
            case Notification.Name.userSignedIn: return Transition.signIn
            case Notification.Name.userSignedOut: return Transition.signOut
            default: fatalError("Wrong notification observed")
            }
        }
        let initial: Transition = User.current == nil ? .signOut : .signIn
        transitionTo = Property<TransitionType>(initial: initial, then: then)
    }
}
