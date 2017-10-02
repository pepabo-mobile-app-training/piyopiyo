//
//  UserFeedTests.swift
//  piyopiyoUITests
//
//  Created by shohei.ogata on 2017/09/28.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import XCTest
import WebKit

@testable import piyopiyo

class UserFeedControllerTests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testLoadInitialPage() {
        let app = XCUIApplication()
        
        app.buttons["はじめる"].tap()
        
        let gotoButton = app.buttons["GotoWebView"]
        XCTAssertTrue(gotoButton.waitForExistence(timeout: 10))
        gotoButton.tap()
        
        XCTAssertTrue(app.otherElements["userFeedWebView"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons[">"].exists)
        XCTAssertTrue(app.buttons["<"].exists)
        XCTAssertFalse(app.buttons[">"].isEnabled)
        XCTAssertFalse(app.buttons["<"].isEnabled)
    }
    
}
