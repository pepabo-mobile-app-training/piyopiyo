//
//  UserProfileTests.swift
//  piyopiyoTests
//
//  Created by shohei.ogata on 2017/10/04.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import XCTest
@testable import piyopiyo

class UserProfileTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFetchUserProfile() {
        let fetchUserProfileExpectation: XCTestExpectation? = self.expectation(description: "fetchUserProfile")

        MicropostUserProfile.fetchUserProfile(userID: 1) { profile in
            XCTAssertEqual(profile.userID, 1)
            XCTAssertFalse(profile.name.isEmpty)
            XCTAssertNotNil(profile.avatarURL)
            fetchUserProfileExpectation?.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
}
