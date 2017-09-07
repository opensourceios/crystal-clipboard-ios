//
//  TestAPIProvider.swift
//  CrystalClipboardTests
//
//  Created by Justin Mazzocchi on 9/7/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Moya
@testable import CrystalClipboard

fileprivate struct ClipWithUser: ClipType, Codable {
    private enum CodingKeys: String, CodingKey {
        case id, text, createdAt = "created_at", user
    }
    
    let id: Int
    let text: String
    let createdAt: Date
    private let user: User
    
    init(id: Int, text: String, createdAt: Date, user: User) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
        self.user = user
    }
}

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
            var errors = [RemoteError]()
            if testData.userForEmail(email) != nil {
                errors.append(RemoteError(message: "Email has already been taken"))
            }
            if password.count < 6 {
                errors.append(RemoteError(message: "Password is too short (minimum is 6 characters)"))
            }
            if errors.count > 0 {
                return .networkResponse(422, encode(RemoteErrors(errors: errors)))
            } else {
                let createdUser = testData.createUser(email: email, password: password)!
                return .networkResponse(201, encode(createdUser))
            }
        case let .signIn(email, password):
            guard
                let user = testData.authenticate(email: email, password: password) else {
                    return .networkResponse(401, encode(RemoteErrors(errors: [RemoteError(message: "The email or password provided was incorrect")])))
            }
            return .networkResponse(200, encode(user))
        case let .resetPassword(email):
            if email == "satan@hell.org" {
                return .networkResponse(204, Data())
            } else {
                return .networkResponse(404, "{\"errors\":[{\"message\":\"Record not found\"}]}".data(using: .utf8)!)
            }
        case .signOut: return .networkResponse(204, Data())
        case .me:
            return .networkResponse(200, "{\"id\":666,\"email\":\"satan@hell.org\"}".data(using: .utf8)!)
        case let .listClips(maxID, count):
            let sampleClipStrings = testData.clipStrings
            var max = maxID ?? sampleClipStrings.count
            max = min(max, sampleClipStrings.count)
            let maxStrings = max < sampleClipStrings.count ? Array(sampleClipStrings[(sampleClipStrings.count - max + 1)...]) : sampleClipStrings
            return .networkResponse(200, "[\(maxStrings[..<(count ?? 25)].joined(separator: ","))]".data(using: .utf8)!)
        case let .createClip(text):
            let clipString = "{\"id\":\(testData.clipStrings.count + 1),\"text\":\"\(text)\",\"created_at\":\"\(CrystalClipboardAPI.dateFormatter.string(from: Date()))\",\"user\":{\"id\":666,\"email\":\"satan@hell.org\"}}"
            testData.clipStrings.insert(clipString, at: 0)
            return .networkResponse(201, clipString.data(using: .utf8)!)
        case let .deleteClip(id):
            if let index = testData.clipStrings.index(where: {
                (try! JSONSerialization.jsonObject(with: $0.data(using: .utf8)!) as! [String: Any])["id"] as! Int == id
            }) {
                testData.clipStrings.remove(at: index)
                return .networkResponse(204, Data())
            } else {
                return .networkResponse(404, "{\"errors\":[{\"message\":\"Record not found\"}]}".data(using: .utf8)!)
            }
        }
    }
    
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.iso8601DateFormat
        return dateFormatter
    }()
}
