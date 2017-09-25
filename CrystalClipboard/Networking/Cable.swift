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
    
    // MARK: Cases
    
    case cableDisconnected
}

enum ChannelEvent {
    
    // MARK: Cases
    
    case confirmSubscription
    case message(message: Any)
    case unknown(dictionary: [String: Any])
    
    // MARK: Internal initializers
    
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
    
    // MARK: Type aliases
    
    typealias Connection = Signal<Event, Error>
    
    // MARK: Internal enums
    
    enum Event {
        
        // MARK: Cases
        
        case connected
        case welcome
        case ping(message: Int)
        case unknown(dictionary: [String: Any])
        
        // MARK: Internal initializers
        
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
        
        // MARK: Cases
        
        case disconnected(underlying: Swift.Error)
    }
    
    // MARK: Private structs
    
    private struct Command: Codable {
        
        // MARK: Internal enums
        
        enum Command: String, Codable {
            
            // MARK: Cases
            
            case subscribe, unsubscribe
        }
        
        // MARK: Internal stored properties
        
        let command: Command
        let identifier: String
    }
    
    // MARK: Private stored properties
    
    private let socket: WebSocket
    private let encoder = JSONEncoder()
    private var connectionInput: Connection.Observer?
    private var channelInputs = [String: Channel.Observer]()
    
    // MARK: Internal initializers
    
    init(url: URL, origin: String?, token: String?) {
        socket = WebSocket(url: url)
        if let token = token {
            socket.headers["Authorization"] = "Bearer " + token
        }
        socket.origin = origin
        socket.delegate = self
        socket.callbackQueue = Cable.queue
        socket.security = SSLSecurity(usePublicKeys: true)
    }
}

extension Cable {
    
    // MARK: Internal computed properties
    
    var isConnected: Bool {
        return socket.isConnected
    }
    
    // MARK: Internal methods
    
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
        Cable.queue.async { [unowned self] in
            self.command(Command(command: .subscribe, identifier: channelIdentifier))
        }
        let channel = Channel.pipe()
        channelInputs[channelIdentifier] = channel.input
        return channel.output
    }
    
    func unsubscribe(channelIdentifier: String) {
        Cable.queue.async { [unowned self] in
            self.command(Command(command: .unsubscribe, identifier: channelIdentifier))
        }
    }
}

private extension Cable {
    
    // MARK: Private constants
    
    private static let queue = DispatchQueue(label: "com.jzzocc.crystal-clipboard.cable-queue", attributes: .concurrent)
    
    // MARK: Private methods
    
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
    
    // MARK: WebSocketDelegate internal methods
    
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
