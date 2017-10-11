//
//  RandomMicroposts.swift
//  piyopiyo
//
//  Created by shohei.ogata on 2017/10/03.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import Foundation
import SwiftyJSON

class Micropost {
    var userID: Int
    var content: String
    
    init(content: String, userID: Int) {
        self.content = content
        self.userID = userID
    }
    
    static func jsonToMicroposts(_ json: JSON) -> [Micropost] {
        return json["microposts"].arrayValue.map {
            Micropost(content: $0["content"].stringValue, userID: $0["user_id"].intValue)
        }
    }
    
    static func fetchRandomMicroposts(handler: @escaping (([Micropost]) -> Void)) {
        APIClient.request(endpoint: Endpoint.randomMicroposts) { json in
            handler(jsonToMicroposts(json))
        }
    }
    
    static func fetchUsersMicroposts(userID: Int, handler: @escaping (([Micropost]) -> Void)) {
        APIClient.request(endpoint: Endpoint.userFeed(userID)) { json in
            handler(jsonToMicroposts(json))
        }
    }
}
