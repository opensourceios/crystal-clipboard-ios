//
//  TestAPIProvider.swift
//  CrystalClipboardTests
//
//  Created by Justin Mazzocchi on 9/7/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Moya
@testable import CrystalClipboard

class TestAPIProvider: APIProvider {
    init(testData: TestData, online: Bool = true) {
        let endpointClosure = { (target: CrystalClipboardAPI) -> Endpoint<CrystalClipboardAPI> in
            let sampleResponseClosure: Endpoint<CrystalClipboardAPI>.SampleResponseClosure = {
                if online {
                    return target.sampleResponse(testData: testData)
                } else {
                    let error = NSError(
                        domain: NSURLErrorDomain,
                        code: -1009,
                        userInfo: ["NSLocalizedDescription": "The Internet connection appears to be offline."]
                    )
                    return .networkError(error)
                }
            }
            return Endpoint<CrystalClipboardAPI>(
                url: URL(target: target).absoluteString,
                sampleResponseClosure: sampleResponseClosure,
                task: target.task
            )
        }
        super.init(endpointClosure: endpointClosure, stubClosure: MoyaProvider.immediatelyStub)
    }
}

extension CrystalClipboardAPI {
    private static let encoder = ISO8601JSONEncoder()
    
    private func encode<T>(_ value: T) -> Data where T : Encodable {
        return try! CrystalClipboardAPI.encoder.encode(value)
    }
    
    fileprivate func sampleResponse(testData: TestData) -> EndpointSampleResponse {
        switch self {
        case let .createUser(email, password):
            do {
                let user = try testData.createUser(email: email, password: password)
                return .networkResponse(201, encode(user))
            } catch let errors as TestData.UserCreationErrors {
                return .networkResponse(422, encode(errors))
            } catch {
                fatalError()
            }
        case let .signIn(email, password):
            do {
                let user = try testData.signIn(email: email, password: password)
                return .networkResponse(200, encode(user))
            } catch TestData.AuthenticationError.wrongPassword {
                return .networkResponse(401, encode(RemoteErrors(errors: [RemoteError(message: "The email or password provided was incorrect")])))
            } catch {
                fatalError()
            }
        case let .resetPassword(email):
            do {
                let _ = try testData.userForEmail(email)
                return .networkResponse(204, Data())
            } catch TestData.RecordError.notFound {
                return .networkResponse(404, encode(RemoteErrors(errors: [RemoteError(message: "Record not found")])))
            } catch {
                fatalError()
            }
        case .signOut:
            do {
                try testData.signOut()
                return .networkResponse(204, Data())
            } catch TestData.AuthenticationError.unauthenticated {
                return .networkResponse(401, Data())
            } catch {
                fatalError()
            }
        case .me:
            guard let user = testData.signedInUser else { return .networkResponse(401, Data()) }
            return .networkResponse(200, encode(user))
        case let .listClips(maxID, count):
            do {
                let clips = try testData.listClips(maxID: maxID, count: count)
                return .networkResponse(200, encode(clips))
            } catch TestData.AuthenticationError.unauthenticated {
                return .networkResponse(401, Data())
            } catch {
                fatalError()
            }
        case let .createClip(text):
            do {
                let clip = try testData.createClip(text: text)
                return .networkResponse(201, encode(clip))
            } catch TestData.AuthenticationError.unauthenticated {
                return .networkResponse(401, Data())
            } catch TestData.ClipError.textMissing {
                let error = RemoteError(message: "Text is too short (minimum is 1 character)")
                return .networkResponse(422, encode(RemoteErrors(errors: [error])))
            } catch let TestData.ClipError.textTooLong(limit) {
                let error = RemoteError(message: "Text is too long (maximum is \(limit) characters)")
                return .networkResponse(422, encode(RemoteErrors(errors: [error])))
            } catch {
                fatalError()
            }
        case let .deleteClip(id):
            do {
                try testData.deleteClip(id: id)
                return .networkResponse(204, Data())
            } catch TestData.RecordError.notFound {
                return .networkResponse(404, encode(RemoteErrors(errors: [RemoteError(message: "Record not found")])))
            } catch {
                fatalError()
            }
        }
    }
}
