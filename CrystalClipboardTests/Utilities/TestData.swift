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
    private var users = [User]()
    private var passwordsForUserIDs = [Int: String]()
    private var signedInUser: User?
    
    func createUser(email: String, password: String) -> User? {
        guard userForEmail(email) == nil else { return nil }
        let user = User(id: users.last?.id ?? 0 + 1, email: email, authToken: User.AuthToken(token: NSUUID().uuidString))
        users.append(user)
        signedInUser = user
        passwordsForUserIDs[user.id] = password
        return user
    }
    
    func userForEmail(_ email: String) -> User? {
        guard let index = users.index(where: { $0.email == email }) else { return nil }
        return users[index]
    }
    
    func authenticate(email: String, password: String) -> User? {
        guard let user = userForEmail(email), passwordsForUserIDs[user.id] == password else { return nil }
        signedInUser = user
        return User(id: user.id, email: user.email, authToken: User.AuthToken(token: NSUUID().uuidString))
    }
    
    var clipStrings: [String] = (1...88).map { "{\"id\":\($0),\"text\":\"\(NSUUID().uuidString)\",\"created_at\":\"\(dateFormatter.string(from: Date()))\",\"user\":{\"id\":666,\"email\":\"satan@hell.org\"}}" }.reversed()
    
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.iso8601DateFormat
        return dateFormatter
    }()
}
