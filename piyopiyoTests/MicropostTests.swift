//
//  ApiClientTests.swift
//  piyopiyoTests
//
//  Created by shohei.ogata on 2017/10/03.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import XCTest
@testable import piyopiyo

class MicropostTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFatchRandomMicroposts() {
        let fetchRandomMicropostExpectation: XCTestExpectation? = self.expectation(description: "fetchRandomMicroposts")

        Micropost.fetchRandomMicroposts() { microposts in
            XCTAssertEqual(microposts.count, 10)
            fetchRandomMicropostExpectation?.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)

    }
    
    func testFetchUsersMicroposts() {
        let fetchUsersMicropostExpectation: XCTestExpectation? = self.expectation(description: "fetchUsersMicroposts")
        
        Micropost.fetchUsersMicroposts(userID: "1") { microposts in
            XCTAssertNotEqual(microposts.count, 0)
            fetchUsersMicropostExpectation?.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
}
