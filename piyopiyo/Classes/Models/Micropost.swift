//
//  RandomMicroposts.swift
//  piyopiyo
//
//  Created by shohei.ogata on 2017/10/03.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import Foundation

class Micropost {
    var userID: Int
    var content: String
    
    init(content: String, userID: Int) {
        self.content = content
        self.userID = userID
    }
    
    static func fetchRandomMicroposts(handler: @escaping ((Array<Micropost>) -> Void)) {
        APIClient.request(endpoint: Endpoint.randomMicroposts) { json in
            let randomMicroposts = json["microposts"].arrayValue.map {
                Micropost(content: $0["content"].stringValue, userID: $0["user_id"].intValue)
            }
            
            handler(randomMicroposts)
        }
    }
}
