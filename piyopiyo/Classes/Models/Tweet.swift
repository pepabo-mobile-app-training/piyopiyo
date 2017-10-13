//
//  Tweet.swift
//  piyopiyo
//
//  Created by shohei.ogata on 2017/10/13.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import Foundation

class Tweet: MicroContent {
    var userID: String
    var content: String
    
    init(content: String, userID: String) {
        self.content = content
        self.userID = userID
    }
}
