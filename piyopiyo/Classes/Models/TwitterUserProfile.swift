//
//  TwitterUserProfile.swift
//  piyopiyo
//
//  Created by shohei.ogata on 2017/10/13.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import Foundation

class TwitterUserProfile: UserProfile {
    var userID: String
    var name: String
    var avatarURL: URL?
    
    init(name: String, userID: String, avatarURL: URL?) {
        self.name = name
        self.userID = userID
        self.avatarURL = avatarURL
    }
}
