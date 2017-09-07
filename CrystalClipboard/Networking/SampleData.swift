//
//  SampleData.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/20/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Moya

extension MoyaProvider where Target == CrystalClipboardAPI {
    static func testingProvider(online: Bool = true) -> APIProvider {
        let endpointClosure = { (target: CrystalClipboardAPI) -> Endpoint<CrystalClipboardAPI> in
            return Endpoint<CrystalClipboardAPI>(
                url: URL(target: target).absoluteString,
                sampleResponseClosure: {
                    if online {
                        return target.sampleResponse
                    } else {
                        let error = NSError(
                            domain: NSURLErrorDomain,
                            code: -1009,
                            userInfo: ["NSLocalizedDescription": "The Internet connection appears to be offline."]
                        )
                        return .networkError(error)
                    }
            },
                task: target.task
            )
        }
        return APIProvider(endpointClosure: endpointClosure, stubClosure: MoyaProvider.immediatelyStub)
    }
}

extension CrystalClipboardAPI {
    // Required for TargetType, but we're preferring sampleResponse to always get a status code
    var sampleData: Data {
        guard case let .networkResponse(_, data) = sampleResponse else { fatalError("sampleResponse should always have data") }
        return data
    }
    
    var sampleResponse: EndpointSampleResponse {
        switch self {
        case let .createUser(email, password):
            var errors = [[String: Any]]()
            if email == "satan@hell.org" {
                errors.append(["message": "Email has already been taken"])
            }
            if password.count < 6 {
                errors.append(["message": "Password is too short (minimum is 6 characters)"])
            }
            if errors.count > 0 {
                return .networkResponse(422, try! JSONSerialization.data(withJSONObject: ["errors": errors]))
            } else {
                return .networkResponse(201, "{\"id\":\(arc4random_uniform(999) + 1),\"email\":\"\(email)\",\"auth_token\":{\"token\":\"qz6oF9nHysGnkVYZccFJGZuz\"}}".data(using: .utf8)!)
            }
        case let .signIn(email, password):
            switch (email, password) {
            case ("satan@hell.org", "password"):
                return .networkResponse(200, "{\"id\":666,\"email\":\"satan@hell.org\",\"auth_token\":{\"token\":\"Vy5KbYX116Y1him376FvAhkw\"}}".data(using: .utf8)!)
            default:
                return .networkResponse(401, "{\"errors\":[{\"message\":\"The email or password provided was incorrect\"}]}".data(using: .utf8)!)
            }
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
            let sampleClipStrings = CrystalClipboardAPI.sampleClipStrings
            var max = maxID ?? sampleClipStrings.count
            max = min(max, sampleClipStrings.count)
            let maxStrings = max < sampleClipStrings.count ? Array(sampleClipStrings[(sampleClipStrings.count - max + 1)...]) : sampleClipStrings
            return .networkResponse(200, "[\(maxStrings[..<(count ?? 25)].joined(separator: ","))]".data(using: .utf8)!)
        case let .createClip(text):
            let clipString = "{\"id\":\(CrystalClipboardAPI.sampleClipStrings.count + 1),\"text\":\"\(text)\",\"created_at\":\"\(CrystalClipboardAPI.dateFormatter.string(from: Date()))\",\"user\":{\"id\":666,\"email\":\"satan@hell.org\"}}"
            CrystalClipboardAPI.sampleClipStrings.insert(clipString, at: 0)
            return .networkResponse(201, clipString.data(using: .utf8)!)
        case let .deleteClip(id):
            if let index = CrystalClipboardAPI.sampleClipStrings.index(where: {
                (try! JSONSerialization.jsonObject(with: $0.data(using: .utf8)!) as! [String: Any])["id"] as! Int == id
            }) {
                CrystalClipboardAPI.sampleClipStrings.remove(at: index)
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
    
    private static var sampleClipStrings: [String] = (1...88).map { "{\"id\":\($0),\"text\":\"\(NSUUID().uuidString)\",\"created_at\":\"\(dateFormatter.string(from: Date()))\",\"user\":{\"id\":666,\"email\":\"satan@hell.org\"}}" }.reversed()
}
