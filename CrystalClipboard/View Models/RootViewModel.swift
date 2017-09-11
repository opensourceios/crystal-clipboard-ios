//
//  RootViewModel.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/29/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import CoreData
import ReactiveSwift

protocol TransitionType {
    var storyboardName: StoryboardNames { get }
    var controllerIdentifier: ViewControllerStoryboardIdentifier { get }
    var viewModel: ViewModelType { get }
}

fileprivate enum Transition: TransitionType {
    case signIn(authToken: User.AuthToken, persistentContainer: NSPersistentContainer)
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
    
    var viewModel: ViewModelType {
        switch self {
        case let .signIn(authToken, persistentContainer):
            let provider = APIProvider(token: authToken.token)
            return ClipsViewModel(provider: provider, persistentContainer: persistentContainer, pageSize: 25)
        case .signOut:
            let provider = APIProvider(token: User.AuthToken.admin.token)
            return LandingViewModel(provider: provider)
        }
    }
}

struct RootViewModel: ViewModelType {
    // MARK: Outputs
    
    let transitionTo: Property<TransitionType>
    
    // MARK: Private
    
    private let (lifetime, token) = Lifetime.make()
    private static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CrystalClipboard")
        container.loadPersistentStores { storeDescription, error in
            if let error = error { fatalError("Could not load store: \(error)") }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
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
                return Transition.signIn(authToken: authToken, persistentContainer: RootViewModel.persistentContainer)
            case Notification.Name.userSignedOut: return Transition.signOut
            default: fatalError("Wrong notification observed")
            }
        }
        let initial: Transition
        if let authToken = User.current?.authToken {
            initial = .signIn(authToken: authToken, persistentContainer: RootViewModel.persistentContainer)
        } else {
            initial = .signOut
        }
        transitionTo = Property<TransitionType>(initial: initial, then: then)
    }
}
