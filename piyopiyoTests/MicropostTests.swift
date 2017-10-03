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
        Micropost.fetchRandomMicroposts() { micropost in
            XCTAssertEqual(micropost.count, 10)
        }
    }
    
}
