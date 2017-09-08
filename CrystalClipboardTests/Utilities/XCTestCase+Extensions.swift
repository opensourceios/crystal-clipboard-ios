//
//  XCTestCase+Extensions.swift
//  CrystalClipboardTests
//
//  Created by Justin Mazzocchi on 9/7/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest
@testable import CrystalClipboard

extension XCTestCase {
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.iso8601DateFormat
        return dateFormatter
    }()
    
    func generateString(length: Int? = nil) -> String {
        return NSUUID().uuidString
    }
    
    func generateEmail() -> String {
        return "\(generateString())@crystalclipboard.com"
    }
    
    func generateNumber(range: Range<UInt32>? = nil) -> Int {
        let lowerBound = range?.lowerBound ?? 0
        let upperBound = range?.upperBound ?? UInt32.max
        
        return Int(lowerBound + arc4random_uniform(UInt32(upperBound - lowerBound)))
    }
    
    func expect(after: TimeInterval, by: TimeInterval, description: String,  execute: @escaping () -> Void, handler: XCWaitCompletionHandler? = nil) {
        let expect = expectation(description: description)
        DispatchQueue.main.asyncAfter(deadline: .now() + after) {
            execute()
            expect.fulfill()
        }
        waitForExpectations(timeout: by, handler: handler)
    }
}
