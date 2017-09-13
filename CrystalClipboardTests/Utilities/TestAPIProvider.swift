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
    
    // MARK: Internal initializers
    
    required init(testRemoteData: TestRemoteData,
                  online: Bool = true,
                  requestClosure: @escaping RequestClosure = MoyaProvider.defaultRequestMapping,
                  stubClosure: @escaping StubClosure = MoyaProvider.immediatelyStub,
                  callbackQueue: DispatchQueue? = nil,
                  manager: Manager = MoyaProvider<Target>.defaultAlamofireManager(),
                  plugins: [PluginType] = [],
                  trackInflights: Bool = false) {
        
        let endpointClosure = { (target: CrystalClipboardAPI) -> Endpoint<CrystalClipboardAPI> in
            let sampleResponseClosure: Endpoint<CrystalClipboardAPI>.SampleResponseClosure = {
                if online {
                    return target.sampleResponse(testRemoteData: testRemoteData)
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
        
        super.init(endpointClosure: endpointClosure,
                   requestClosure: requestClosure,
                   stubClosure: stubClosure,
                   callbackQueue: callbackQueue,
                   manager: manager,
                   plugins: plugins,
                   trackInflights: trackInflights)
    }
}

private extension CrystalClipboardAPI {
    
    // MARK: Private constants
    
    private static let encoder = ISO8601JSONEncoder()
    
    // MARK: Private methods
    
    private func encode<T>(_ value: T) -> Data where T : Encodable {
        return try! CrystalClipboardAPI.encoder.encode(value)
    }
}

fileprivate extension CrystalClipboardAPI {
    
    // MARK: Fileprivate methods
    
    fileprivate func sampleResponse(testRemoteData: TestRemoteData) -> EndpointSampleResponse {
        switch self {
        case let .createUser(email, password):
            do {
                let user = try testRemoteData.createUser(email: email, password: password)
                return .networkResponse(201, encode(user))
            } catch let errors as RemoteErrors {
                return .networkResponse(422, encode(errors))
            } catch {
                fatalError()
            }
        case let .signIn(email, password):
            do {
                let user = try testRemoteData.signIn(email: email, password: password)
                return .networkResponse(200, encode(user))
            } catch let errors as RemoteErrors where errors == TestRemoteData.wrongEmailPasswordError {
                return .networkResponse(401, encode(errors))
            } catch {
                fatalError()
            }
        case let .resetPassword(email):
            do {
                let _ = try testRemoteData.userForEmail(email)
                return .networkResponse(204, Data())
            } catch let errors as RemoteErrors where errors == TestRemoteData.recordNotFoundError {
                return .networkResponse(404, encode(errors))
            } catch {
                fatalError()
            }
        case .signOut:
            do {
                try testRemoteData.signOut()
                return .networkResponse(204, Data())
            } catch let errors as RemoteErrors where errors == TestRemoteData.unauthenticatedError {
                return .networkResponse(401, encode(errors))
            } catch {
                fatalError()
            }
        case .me:
            guard let user = testRemoteData.signedInUser else { return .networkResponse(401, Data()) }
            return .networkResponse(200, encode(user))
        case let .listClips(maxID, count):
            do {
                let clips = try testRemoteData.listClips(maxID: maxID, count: count)
                return .networkResponse(200, encode(clips))
            } catch let errors as RemoteErrors where errors == TestRemoteData.unauthenticatedError {
                return .networkResponse(401, encode(errors))
            } catch {
                fatalError()
            }
        case let .createClip(text):
            do {
                let clip = try testRemoteData.createClip(text: text)
                return .networkResponse(201, encode(clip))
            } catch let errors as RemoteErrors where errors == TestRemoteData.unauthenticatedError {
                return .networkResponse(401, encode(errors))
            } catch
                let errors as RemoteErrors
                where (errors == TestRemoteData.clipTextMissingError) || (errors == TestRemoteData.clipTextTooLongError) {
                return .networkResponse(422, encode(errors))
            } catch {
                fatalError()
            }
        case let .deleteClip(id):
            do {
                try testRemoteData.deleteClip(id: id)
                return .networkResponse(204, Data())
            } catch let errors as RemoteErrors where errors == TestRemoteData.recordNotFoundError {
                return .networkResponse(404, encode(errors))
            } catch {
                fatalError()
            }
        }
    }
}
