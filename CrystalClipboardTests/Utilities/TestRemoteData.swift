//
//  TestRemoteData.swift
//  CrystalClipboardTests
//
//  Created by Justin Mazzocchi on 9/7/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Foundation
@testable import CrystalClipboard

class TestRemoteData {
    
    // MARK: Internal stored properties
    
    private(set) var signedInUser: User?
    
    // MARK: Private stored properties
    
    private var users = [User]()
    private var passwordsForUserIDs = [Int: String]()
    private var clips = [Clip]()
}

extension TestRemoteData {
    
    // MARK: Internal constants
    
    static let recordNotFoundError = RemoteErrors(errors: [RemoteError(message: "Record not found")])
    static let wrongEmailPasswordError = RemoteErrors(errors: [RemoteError(message: "The email or password provided was incorrect")])
    static let unauthenticatedError = RemoteErrors(errors: [RemoteError(message: "You need to sign up or sign in before continuing")])
    static let clipTextMissingError = RemoteErrors(errors: [RemoteError(message: "Text is too short (minimum is 1 character)")])
    static let clipTextTooLongError = RemoteErrors(errors: [RemoteError(message: "Text is too long (maximum is \(clipTextLimit) characters)")])
    
    // MARK: Internal methods
    
    @discardableResult
    func createUser(email: String, password: String) throws -> User {
        var errors = [RemoteError]()
        do {
            _ = try userForEmail(email)
            errors.append(RemoteError(message: "Email has already been taken"))
        } catch let error as RemoteErrors where error == TestRemoteData.recordNotFoundError {
            // do nothing
        } catch {
            fatalError()
        }
        if password.count < TestRemoteData.minPasswordLength {
            errors.append(RemoteError(message: "Password is too short (minimum is \(TestRemoteData.minPasswordLength) characters)"))
        }
        guard errors.count == 0 else { throw RemoteErrors(errors: errors) }
        
        let user = User(id: (users.last?.id ?? 0) + 1, email: email, authToken: User.AuthToken(token: NSUUID().uuidString))
        users.append(user)
        signedInUser = user
        passwordsForUserIDs[user.id] = password
        
        return user
    }
    
    func userForEmail(_ email: String) throws -> User {
        guard let index = users.index(where: { $0.email == email }) else { throw TestRemoteData.recordNotFoundError }
        
        return users[index]
    }
    
    func signIn(email: String, password: String) throws -> User {
        guard let user = try? userForEmail(email), passwordsForUserIDs[user.id] == password else { throw TestRemoteData.wrongEmailPasswordError }
        
        signedInUser = user
        return User(id: user.id, email: user.email, authToken: User.AuthToken(token: NSUUID().uuidString))
    }
    
    func signOut() throws {
        try authenticate()
        
        signedInUser = nil
        clips = [Clip]()
    }
    
    @discardableResult
    func createClip(text: String) throws -> Clip {
        let limit = TestRemoteData.clipTextLimit
        let user = try authenticate()
        guard text.count > 0 else { throw TestRemoteData.clipTextMissingError }
        guard text.count < limit else { throw TestRemoteData.clipTextTooLongError }
        
        let clip = Clip(id: (clips.last?.id ?? 0) + 1, text: text, userID: user.id, createdAt: Date())
        clips.append(clip)
        return clip
    }
    
    func listClips(maxID: Int?, count: Int?) throws -> [Clip] {
        try authenticate()
        let actualMaxID: Int
        if let maxID = maxID, maxID < clips.count {
            actualMaxID = maxID - 1
        } else {
            actualMaxID = clips.count
        }
        let actualCount: Int
        if let count = count, count < TestRemoteData.maxCount {
            actualCount = count
        } else {
            actualCount = TestRemoteData.defaultCount
        }
        
        let maxClips = Array(clips[..<actualMaxID].reversed())
        return Array(maxClips[..<(min(actualCount, maxClips.count))])
    }
    
    func deleteClip(id: Int) throws {
        try authenticate()
        
        guard let index = clips.index(where: { $0.id == id }) else { throw TestRemoteData.recordNotFoundError }
        clips.remove(at: index)
    }
}

private extension TestRemoteData {
    
    // MARK: Private constants
    
    private static let minPasswordLength = 6
    private static let clipTextLimit = 5000
    private static let defaultCount = 25
    private static let maxCount = 100
    
    // MARK: Private methods
    
    @discardableResult
    private func authenticate() throws -> User {
        guard let user = signedInUser else { throw TestRemoteData.unauthenticatedError }
        return user
    }
}
