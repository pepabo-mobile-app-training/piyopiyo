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
        UserProfile.fetchUserProfile(userID: 1) { profiles in
            XCTAssertEqual(profiles.userID, 1)
        }
    }
    
}
