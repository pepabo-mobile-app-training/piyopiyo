//
//  ContinuityMicropostsTests.swift
//  piyopiyoTests
//
//  Created by shohei.ogata on 2017/10/05.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import XCTest
@testable import piyopiyo

class ContinuityMicropostsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGetMicroposts() {
        let microposts = ContinuityMicroposts()
        microposts.fetchMicroposts()
        
        //初回Micropost取得の成功が３秒以内に終了するか否かを確認
        let fetchFirstMicropostExpectation: XCTestExpectation? = self.expectation(description: "fetchFirstMicroposts")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            XCTAssertEqual(microposts.count, 10)
            fetchFirstMicropostExpectation?.fulfill()
        }
        waitForExpectations(timeout: 4, handler: nil)
        
        //取得したMicropostが正しく取得できるかどうかを確認
        for _ in 0..<7 {
            XCTAssertNotNil(microposts.getMicropost())
        }

        //Micropostが一定数を下回った時に新たにMicropostを取りに行ってくれているかどうか確認
        let fetchSecondMicropostExpectation: XCTestExpectation? = self.expectation(description: "fetchSecondMicroposts")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            XCTAssertEqual(microposts.count, 13)
            fetchSecondMicropostExpectation?.fulfill()
        }
        waitForExpectations(timeout: 4, handler: nil)
    }
}
