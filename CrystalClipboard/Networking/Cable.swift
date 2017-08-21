//
//  Cable.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/20/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Foundation
import ReactiveSwift
import Starscream

enum ChannelError: Error {
    case cableDisconnected
}

typealias CableSignal = Signal<Cable.Event, NSError>
typealias ChannelSignal = Signal<Cable.Event.Channel, ChannelError>
typealias CableObserver = Signal<Cable.Event, NSError>.Observer
typealias ChannelObserver = Signal<Cable.Event.Channel, ChannelError>.Observer

class Cable {
    enum Event {
        case connected
        case welcome
        case ping(message: Int)
        
        init?(json: [String: Any]) {
            guard let type = json["type"] as? String else { return nil }
            switch (type, json["message"]) {
            case ("welcome", nil): self = .welcome
            case ("ping", let message as Int): self = .ping(message: message)
            default: return nil
            }
        }
        
        enum Channel {
            case confirmSubscription
            case message(message: [String: Any])
            
            init?(json: [String: Any]) {
                if let type = json["type"] as? String {
                    switch type {
                    case "confirm_subscription": self = .confirmSubscription
                    default: return nil
                    }
                } else if let message = json["message"] as? [String: Any] {
                    self = .message(message: message)
                } else {
                    return nil
                }
            }
        }
    }
    
    private enum Command {
        case subscribe(channelIdentifier: String)
        case unsubscribe(channelIdentifier: String)
        
        var string: String {
            switch self {
            case .subscribe: return "subscribe"
            case .unsubscribe: return "unsubscribe"
            }
        }
    }

    
    private let socket: WebSocket
    fileprivate var observer: CableObserver?
    fileprivate var channelObservers = [String: ChannelObserver]()
    fileprivate let queue = DispatchQueue(label: "com.jzzocc.crystal-clipboard.cable-queue", attributes: .concurrent)
    
    init(authToken: String) {
        let cableURLString = Bundle.main.infoDictionary!["com.jzzocc.crystal-clipboard.cable-url"] as! String
        let cableURL = URL(string: cableURLString)!
        self.socket = WebSocket(url: cableURL)
        self.socket.headers["Authorization"] = "Bearer \(authToken)"
        self.socket.origin = Bundle.main.infoDictionary!["com.jzzocc.crystal-clipboard.cable-origin"] as? String
        self.socket.delegate = self
        self.socket.callbackQueue = self.queue
    }
    
    func connect() -> CableSignal {
        self.socket.connect()
        let (signal, observer) = CableSignal.pipe()
        self.observer = observer
        return signal
    }
    
    func subscribe(channelIdentifier: String) -> ChannelSignal {
        self.queue.async { [unowned self] in
            self.command(.subscribe(channelIdentifier: channelIdentifier))
        }
        let (channel, observer) = ChannelSignal.pipe()
        channelObservers[channelIdentifier] = observer
        return channel
    }
    
    func unsubscribe(channelIdentifier: String) {
        self.queue.async { [unowned self] in
            self.command(.unsubscribe(channelIdentifier: channelIdentifier))
        }
    }
    
    private func command(_ command: Command) {
        var commandObject = ["command": command.string]
        
        switch command {
        case .subscribe(let channelIdentifier), .unsubscribe(let channelIdentifier):
            commandObject["identifier"] = channelIdentifier
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: commandObject) else { fatalError("Command should be serializable to JSON") }
        guard let string = String(data: data, encoding: .utf8) else { fatalError("JSON data should be a string") }
        
        self.socket.write(string: string) { [unowned self] in
            switch command {
            case .unsubscribe(let channelIdentifier):
                self.channelObservers[channelIdentifier]?.sendCompleted()
            default: break
            }
        }
    }
}

extension Cable: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocket) {
        self.observer?.send(value: .connected)
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        if let error = error {
            for channelObserver in channelObservers.values {
                channelObserver.send(error: ChannelError.cableDisconnected)
            }
            self.observer?.send(error: error)
        } else {
            self.observer?.sendCompleted()
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        guard let data = text.data(using: .utf8) else { fatalError("Text should be a UTF8 string") }
        guard let deserializedMessage = try? JSONSerialization.jsonObject(with: data) else { fatalError("Text should be valid JSON") }
        guard let message = deserializedMessage as? [String: Any] else { fatalError("Message should be a dictionary") }
        
        if let identifier = message["identifier"] as? String, let channelObserver = channelObservers[identifier] {
            if let channelEvent = Event.Channel(json: message) {
                channelObserver.send(value: channelEvent)
            } else {
                print(message)
            }
        } else {
            if let event = Event(json: message) {
                self.observer?.send(value: event)
            } else {
                print(message)
            }
        }
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        fatalError("Socket should only receive text and not binary data")
    }
}
