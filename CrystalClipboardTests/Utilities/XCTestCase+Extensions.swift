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
    static let ISO8601FractionalSecondDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.iso8601DateFormat
        return dateFormatter
    }()
    
    func expect(after: TimeInterval, by: TimeInterval, description: String,  execute: @escaping () -> Void, handler: XCWaitCompletionHandler? = nil) {
        let expect = expectation(description: description)
        DispatchQueue.main.asyncAfter(deadline: .now() + after) {
            execute()
            expect.fulfill()
        }
        waitForExpectations(timeout: by, handler: handler)
    }
}
