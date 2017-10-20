//
//  User.swift
//  piyopiyo
//
//  Created by shohei.ogata on 2017/10/04.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import Foundation

class MicropostUserProfile: UserProfile {
    var userID: String
    var name: String
    var avatarURL: URL?
 
    init(name: String, userID: String, avatarURL: URL?) {
        self.name = name
        self.userID = userID
        self.avatarURL = avatarURL
    }
    
    static func fetchUserProfile(userID: String, handler: @escaping ((MicropostUserProfile) -> Void)) {
        APIClient.request(endpoint: Endpoint.userProfile(userID)) { json in
            let profile = MicropostUserProfile(name: json["name"].stringValue, userID: json["id"].stringValue, avatarURL: URL(string: json["avatar"].stringValue))
            handler(profile)
        }
    }
}
