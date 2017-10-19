//
//  Tweet.swift
//  piyopiyo
//
//  Created by shohei.ogata on 2017/10/13.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import Foundation
import SwifteriOS

class Tweet: MicroContent {
    var userID: String
    var content: String
    var profile: TwitterUserProfile
    
    init(content: String, userID: String, profile: TwitterUserProfile) {
        self.content = content
        self.userID = userID
        self.profile = profile
    }

    static func fetchRandomTweets(swifter: Swifter, handler: @escaping ((Tweet) -> Void)) -> HTTPRequest {
        return swifter.streamRandomSampleTweets(language:  ["ja"], progress: { json in
            guard let content = json["text"].string,
                  let userID = json["user"]["id"].double,
                  let name = json["user"]["name"].string,
                  let url = json["user"]["profile_image_url_https"].string else {

                handler(Tweet(content: "", userID: "", profile: TwitterUserProfile(name: "", userID: "", avatarURL: nil)))

                return
            }
            let profile = TwitterUserProfile(name: name, userID: String(userID), avatarURL: URL(string: url))
            let tweet = Tweet(content: content, userID: String(userID), profile: profile)

            handler(tweet)
        })
    }
}
