//
//  FeedTutorialUITests.swift
//  piyopiyoUITests
//
//  Created by shizuna.ito on 2017/10/19.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import XCTest
@testable import piyopiyo

class FeedTutorialUITests: XCTestCase {
    private let app = XCUIApplication()

    override func setUp() {
        super.setUp()

        continueAfterFailure = false

        // 初回の起動をテストする
        app.launchArguments.append(contentsOf: ["-startApp", "NO"])
        app.launch()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testTapAppStart() {
        let startButton = app.buttons["startButton"]

        XCTAssert(startButton.exists)

        startButton.tap()

        XCTAssertFalse(startButton.exists)
    }
}
