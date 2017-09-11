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

enum ChannelEvent {
    case confirmSubscription
    case message(message: Any)
    case unknown(dictionary: [String: Any])
    
    init(dictionary: [String: Any]) {
        if let type = dictionary["type"] as? String {
            switch type {
            case "confirm_subscription": self = .confirmSubscription
            default: self = .unknown(dictionary: dictionary)
            }
        } else if let message = dictionary["message"] {
            self = .message(message: message)
        } else {
            self = .unknown(dictionary: dictionary)
        }
    }
}

typealias Channel = Signal<ChannelEvent, ChannelError>

class Cable {
    typealias Connection = Signal<Event, Error>
    
    enum Event {
        case connected
        case welcome
        case ping(message: Int)
        case unknown(dictionary: [String: Any])
        
        init(dictionary: [String: Any]) {
            guard let type = dictionary["type"] as? String else {
                self = .unknown(dictionary: dictionary)
                return
            }
            switch (type, dictionary["message"]) {
            case ("welcome", nil): self = .welcome
            case ("ping", let message as Int): self = .ping(message: message)
            default: self = .unknown(dictionary: dictionary)
            }
        }
    }
    
    enum Error: Swift.Error {
        case disconnected(underlying: Swift.Error)
    }
    
    private struct Command: Codable {
        enum Command: String, Codable {
            case subscribe, unsubscribe
        }
        
        let command: Command
        let identifier: String
    }
    
    private let socket: WebSocket
    private let encoder = JSONEncoder()
    fileprivate var connectionInput: Connection.Observer?
    fileprivate var channelInputs = [String: Channel.Observer]()
    fileprivate let queue = DispatchQueue(label: "com.jzzocc.crystal-clipboard.cable-queue", attributes: .concurrent)
    
    init(url: URL, origin: String?, token: String?) {
        socket = WebSocket(url: url)
        if let token = token {
            socket.headers["Authorization"] = "Bearer " + token
        }
        socket.origin = origin
        socket.delegate = self
        socket.callbackQueue = queue
    }
    
    func connect() -> Connection {
        socket.connect()
        let connection = Connection.pipe()
        connectionInput = connection.input
        return connection.output
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func subscribe(channelIdentifier: String) -> Channel {
        queue.async { [unowned self] in
            self.command(Command(command: .subscribe, identifier: channelIdentifier))
        }
        let channel = Channel.pipe()
        channelInputs[channelIdentifier] = channel.input
        return channel.output
    }
    
    func unsubscribe(channelIdentifier: String) {
        queue.async { [unowned self] in
            self.command(Command(command: .unsubscribe, identifier: channelIdentifier))
        }
    }
    
    private func command(_ command: Command) {
        guard let data = try? encoder.encode(command) else { fatalError("Command should be serializable to JSON") }
        guard let string = String(data: data, encoding: .utf8) else { fatalError("JSON data should be a string") }
        
        socket.write(string: string) { [unowned self] in
            switch command.command {
            case .unsubscribe:
                self.channelInputs[command.identifier]?.sendCompleted()
            default: break
            }
        }
    }
}

extension Cable: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocket) {
        connectionInput?.send(value: .connected)
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        if let error = error {
            for channelObserver in channelInputs.values {
                channelObserver.send(error: ChannelError.cableDisconnected)
            }
            connectionInput?.send(error: Error.disconnected(underlying: error))
        } else {
            connectionInput?.sendCompleted()
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        guard let data = text.data(using: .utf8) else { fatalError("Text should be a UTF8 string") }
        guard let deserializedData = try? JSONSerialization.jsonObject(with: data) else { fatalError("Text should be valid JSON") }
        guard let dictionary = deserializedData as? [String: Any] else { fatalError("Should be a dictionary") }
        
        if let identifier = dictionary["identifier"] as? String {
            channelInputs[identifier]?.send(value: ChannelEvent(dictionary: dictionary))
        } else {
            connectionInput?.send(value: Event(dictionary: dictionary))
        }
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        // Socket should only receive text and not binary data
    }
}
