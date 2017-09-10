//
//  RootViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/29/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import ReactiveSwift

protocol TransitionType {
    var storyboardName: StoryboardNames { get }
    var controllerIdentifier: ViewControllerStoryboardIdentifier { get }
    var provider: APIProvider { get }
}

fileprivate enum Transition: TransitionType {
    case signIn(authToken: User.AuthToken)
    case signOut
    
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
        case let .signIn(authToken):
            return APIProvider(token: authToken.token)
        case .signOut: return APIProvider(token: User.AuthToken.admin.token)
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
            case Notification.Name.userSignedIn:
                guard let authToken = (notification.object as? User)?.authToken else { fatalError("A signed in user should have an auth token") }
                return Transition.signIn(authToken: authToken)
            case Notification.Name.userSignedOut: return Transition.signOut
            default: fatalError("Wrong notification observed")
            }
        }
        let initial: Transition
        if let authToken = User.current?.authToken {
            initial = .signIn(authToken: authToken)
        } else {
            initial = .signOut
        }
        transitionTo = Property<TransitionType>(initial: initial, then: then)
    }
}
