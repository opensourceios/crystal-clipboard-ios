//
//  CrystalClipboardUITests.swift
//  CrystalClipboardUITests
//
//  Created by Justin Mazzocchi on 8/17/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import XCTest

class CrystalClipboardUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // enable when running `fastlane snapshot`
    func DISABLED_testSnapshot() {
        let app = XCUIApplication()
        snapshot("landing")
        app.buttons["Sign In"].tap()
        
        let scrollViewsQuery = app.scrollViews
        let element = scrollViewsQuery.children(matching: .other).element.children(matching: .other).element
        element.children(matching: .other).element(boundBy: 0).children(matching: .textField).element.typeText("screenshots@crystalclipboard.com")
        
        let secureTextField = element.children(matching: .other).element(boundBy: 1).children(matching: .secureTextField).element
        secureTextField.tap()
        secureTextField.tap()
        secureTextField.typeText("screenshots")
        
        let elementsQuery = scrollViewsQuery.otherElements
        elementsQuery.buttons["Sign In"].tap()
        snapshot("clips")
        app.navigationBars["Crystal Clipboard"].buttons["Add"].tap()
        elementsQuery.children(matching: .textView).element.typeText("Bird bath radius: 50cm")
        snapshot("add")
    }
    
}
