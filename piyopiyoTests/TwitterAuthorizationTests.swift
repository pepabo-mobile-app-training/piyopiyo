//
//  TwitterAuthorizationTests.swift
//  piyopiyoTests
//
//  Created by shizuna.ito on 2017/10/13.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import XCTest
@testable import piyopiyo

class TwitterAuthorizationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testAuthorize() {
        let consumerKey = "test_key"
        let consumerSecret = "test_secret"
        let userDefaults = UserDefaults.standard

        let twitterAuthorization = try? TwitterAuthorization(consumerKey: consumerKey, consumerSecret: consumerSecret)

        XCTAssertNotNil(twitterAuthorization)

        UserDefaults.resetStandardUserDefaults()

        userDefaults.set(consumerKey, forKey: "twitter_key")
        userDefaults.set(consumerSecret, forKey: "twitter_secret")

        // すでにキーが存在するときは、クロージャの引数にTrueがセットされる（isAuthorized()メソッドの確認）
        let twitterAuthorizationException: XCTestExpectation? = self.expectation(description: "twitterAuthorization")
        twitterAuthorization!.authorize(presentFrom: UIViewController()) { result in
            XCTAssertTrue(result)
            userDefaults.removeObject(forKey: "twitter_key")
            userDefaults.removeObject(forKey: "twitter_secret")
            twitterAuthorizationException?.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

    }
}
