//
//  User.swift
//  piyopiyo
//
//  Created by shohei.ogata on 2017/10/04.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import Foundation

class UserProfile {
    var userID: Int
    var name: String
    var avatarURL: URL?
 
    init(name: String, userID: Int, avatarURL: URL?) {
        self.name = name
        self.userID = userID
        self.avatarURL = avatarURL
    }
    
    static func fetchUserProfile(userID: Int, handler: @escaping ((UserProfile) -> Void)) {
        APIClient.request(endpoint: Endpoint.userProfile(userID)) { json in
            let profile = UserProfile(name: json["name"].stringValue, userID: json["id"].intValue, avatarURL: URL(string: json["avatar"].stringValue))
            handler(profile)
        }
    }
}
