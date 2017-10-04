//
//  FeedUITests.swift
//  piyopiyoUITests
//
//  Created by shizuna.ito on 2017/09/29.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import XCTest

class FeedUITests: XCTestCase {

    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testTapAppStart() {
        let app = XCUIApplication()
        let startButton = app.buttons["startButton"]
        let durationOfBalloon: TimeInterval = 6.0
        
        XCTAssert(startButton.exists)
        
        startButton.tap()
        XCTAssertFalse(startButton.exists)
        
        for i in 0..<3 {
            XCTAssert(app.textViews["balloonText\(i)"].waitForExistence(timeout: durationOfBalloon))
        }
    }
}
