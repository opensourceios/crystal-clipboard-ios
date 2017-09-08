//
//  TestData.swift
//  CrystalClipboardTests
//
//  Created by Justin Mazzocchi on 9/7/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Foundation
@testable import CrystalClipboard

class TestData {
    typealias UserCreationErrors = RemoteErrors
    typealias UserCreationError = RemoteError
    
    enum AuthenticationError: Error {
        case wrongPassword
        case unauthenticated
    }
    
    enum RecordError: Error {
        case notFound
    }
    
    enum ClipError: Error {
        case textMissing
        case textTooLong(limit: Int)
    }
    
    private static let minPasswordLength = 6
    private static let clipTextLimit = 5000
    private static let defaultCount = 25
    private static let maxCount = 100
    
    private var users = [User]()
    private var passwordsForUserIDs = [Int: String]()
    private var clips = [Clip]()
    
    private(set) var signedInUser: User?
    
    @discardableResult
    func createUser(email: String, password: String) throws -> User {
        var errors = [UserCreationError]()
        do {
            _ = try userForEmail(email)
            errors.append(UserCreationError(message: "Email has already been taken"))
        } catch RecordError.notFound {
            // do nothing
        } catch {
            fatalError()
        }
        if password.count < TestData.minPasswordLength {
            errors.append(UserCreationError(message: "Password is too short (minimum is \(TestData.minPasswordLength) characters)"))
        }
        guard errors.count == 0 else { throw UserCreationErrors(errors: errors) }
        
        let user = User(id: (users.last?.id ?? 0) + 1, email: email, authToken: User.AuthToken(token: NSUUID().uuidString))
        users.append(user)
        signedInUser = user
        passwordsForUserIDs[user.id] = password
        
        return user
    }
    
    func userForEmail(_ email: String) throws -> User {
        guard let index = users.index(where: { $0.email == email }) else { throw RecordError.notFound }
        
        return users[index]
    }
    
    func signIn(email: String, password: String) throws -> User {
        guard let user = try? userForEmail(email), passwordsForUserIDs[user.id] == password else { throw AuthenticationError.wrongPassword }
        
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
        let limit = TestData.clipTextLimit
        let user = try authenticate()
        guard text.count > 0 else { throw ClipError.textMissing }
        guard text.count < limit else { throw ClipError.textTooLong(limit: limit) }
        
        let clip = Clip(id: (clips.last?.id ?? 0) + 1, text: text, createdAt: Date(), user: user)
        clips.append(clip)
        return clip
    }
    
    func listClips(maxID: Int?, count: Int?) throws -> [Clip] {
        try authenticate()
        let actualMaxID: Int
        if let maxID = maxID, maxID < clips.count {
            actualMaxID = maxID
        } else {
            actualMaxID = clips.count
        }
        let actualCount: Int
        if let count = count, count < TestData.maxCount {
            actualCount = count
        } else {
            actualCount = TestData.defaultCount
        }
        
        let maxClips = Array(clips[..<actualMaxID].reversed())
        return Array(maxClips[..<actualCount])
    }
    
    func deleteClip(id: Int) throws {
        try authenticate()
        
        guard let index = clips.index(where: { $0.id == id }) else { throw RecordError.notFound }
        clips.remove(at: index)
    }
}

private extension TestData {
    @discardableResult
    private func authenticate() throws -> User {
        guard let user = signedInUser else { throw AuthenticationError.unauthenticated }
        return user
    }
}
