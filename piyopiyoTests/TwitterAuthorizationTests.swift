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
        let userDefaults = UserDefaults.standard
        
        UserDefaults.resetStandardUserDefaults()
        
        userDefaults.set("test_key", forKey: "twitter_key")
        userDefaults.set("test_secret", forKey: "twitter_secret")
        
        // すでにキーが存在するときfalseを返す（isAuthorized()メソッドの確認）
        XCTAssertFalse(try TwitterAuthorization.authorize(presentFrom: UIViewController()))
        
        userDefaults.removeObject(forKey: "twitter_key")
        userDefaults.removeObject(forKey: "twitter_secret")
    }
}
