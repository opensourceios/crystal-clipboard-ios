//
//  SignalProducer+JSONDeserializableTests.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/24/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
import ReactiveSwift
import Moya
@testable import CrystalClipboard

class SignalProducer_JSONDeserializableTests: XCTestCase {
    let provider = CrystalClipboardAPI.testingProvider()
    
    func testMapDeserializeJSON() {
        var clipsDeserialized = 0
        
        provider.reactive.request(.createClip(text: "deserialize me"))
            .mapJSON()
            .mapDeserializeJSON(to: Clip.self)
            .start { event in
                switch event {
                case let .value(clip):
                    XCTAssertEqual(clip.text, "deserialize me")
                    clipsDeserialized += 1
                case let .failed(error): XCTFail("Failed to deserialize clip: \(error)")
                case .completed: XCTAssertEqual(clipsDeserialized, 1)
                case .interrupted: XCTFail("Should not be interrupted")
                }
        }
    }
    
    func testMapDeserializeJSONMany() {
        var clipsDeserialized = 0
        
        provider.reactive.request(.listClips(page: 1, pageSize: 25))
            .mapJSON()
            .mapDeserializeJSON(toMany: Clip.self)
            .start { event in
                switch event {
                case let .value(clips):
                    XCTAssertEqual(clips.first!.text, "ec1eb9d60c8d136ef1085810d0fe5117")
                    clipsDeserialized += clips.count
                case let .failed(error): XCTFail("Failed to deserialize clip: \(error)")
                case .completed: XCTAssertEqual(clipsDeserialized, 25)
                case .interrupted: XCTFail("Should not be interrupted")
                }
        }
    }
    
    func testMapDeserializeJSONInvalidType() {
        provider.reactive.request(.createClip(text: "I'm a clip, not a user"))
            .mapJSON()
            .mapDeserializeJSON(to: User.self)
            .start { event in
                switch event {
                case let .failed(error):
                    switch error {
                    case let .underlying(underlyingError, _):
                        guard let deserializationError = underlyingError as? JSONDeserializationError else {
                            XCTFail("Wrong error type")
                            return
                        }
                        XCTAssert(deserializationError == JSONDeserializationError.invalidType)
                    default: XCTFail("Wrong error type")
                    }
                default: XCTFail("Should fail")
                }
        }
    }
    
    func testMapDeserializeJSONInvalidStructure() {
        SignalProducer<Response, MoyaError>() { observer, _ in
            let invalidJSON = try! JSONSerialization.data(withJSONObject: ["bad": "stuff"])
            let response = Response(statusCode: 200, data: invalidJSON)
            observer.send(value: response)
            }.mapJSON()
            .mapDeserializeJSON(to: Clip.self)
            .start { event in
                switch event {
                case let .failed(error):
                    switch error {
                    case let .underlying(underlyingError, _):
                        guard let deserializationError = underlyingError as? JSONDeserializationError else {
                            XCTFail("Wrong error type")
                            return
                        }
                        XCTAssert(deserializationError == JSONDeserializationError.invalidStructure)
                    default: XCTFail("Wrong error type")
                    }
                default: XCTFail("Should fail")
                }
        }
    }
    
    func testMapDeserializeJSONInvalidAttributes() {
        SignalProducer<Response, MoyaError>() { observer, _ in
            let invalidDict = ["data": ["id": "1", "type": "clips", "attributes": ["bad": "stuff"]]]
            let invalidJSON = try! JSONSerialization.data(withJSONObject: invalidDict)
            let response = Response(statusCode: 200, data: invalidJSON)
            observer.send(value: response)
            }.mapJSON()
            .mapDeserializeJSON(to: Clip.self)
            .start { event in
                switch event {
                case let .failed(error):
                    switch error {
                    case let .underlying(underlyingError, _):
                        guard let deserializationError = underlyingError as? JSONDeserializationError else {
                            XCTFail("Wrong error type")
                            return
                        }
                        XCTAssert(deserializationError == JSONDeserializationError.invalidAttributes)
                    default: XCTFail("Wrong error type")
                    }
                default: XCTFail("Should fail")
                }
        }
    }
}
