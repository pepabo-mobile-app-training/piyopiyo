//
//  FeedUITests.swift
//  piyopiyoUITests
//
//  Created by shizuna.ito on 2017/09/29.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import XCTest
@testable import piyopiyo

class FeedUITests: XCTestCase {
    private let app = XCUIApplication()

    override func setUp() {
        super.setUp()

        continueAfterFailure = false

        // 2回目以降の起動をテストする
        app.launchArguments.append(contentsOf: ["-startApp", "YES"])
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testAnimateBalloon() {
        let startButton = app.buttons["startButton"]
        let durationOfBalloon: TimeInterval = 6.0
        
        XCTAssertFalse(startButton.exists)
        
        for i in 0..<3 {
            XCTAssert(app.staticTexts["balloonText\(i)"].waitForExistence(timeout: durationOfBalloon))
        }
    }
}
