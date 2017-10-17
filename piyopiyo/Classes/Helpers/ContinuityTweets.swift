//
//  ContinuityTweets.swift
//  piyopiyo
//
//  Created by shizuna.ito on 2017/10/17.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import Foundation
import SwifteriOS

class ContinuityTweets {
    private var tweets = [Tweet]()
    private var isRequestingTweets: Bool = false
    private var request: HTTPRequest?
    static let maxTweetCount = 50
    static let lowestTweetCount = 5

    var count: Int {
        return tweets.count
    }

    func fetchMicroposts() {
        let env = ProcessInfo.processInfo.environment
        let defaults = UserDefaults.standard

        guard let consumerKey = env["consumerKey"], let consumerSecret = env["consumerSecret"],
            let oauthToken = defaults.string(forKey: "twitter_key"), let oauthTokenSecret = defaults.string(forKey: "twitter_secret") else {
                return
        }

        let swifter = Swifter(consumerKey: consumerKey, consumerSecret: consumerSecret, oauthToken: oauthToken, oauthTokenSecret: oauthTokenSecret)

        if !isRequestingTweets {
            isRequestingTweets = true
            request = Tweet.fetchRandomTweets(swifter: swifter) { randomTweet in
                self.tweets.append(randomTweet)

                if self.count == ContinuityTweets.maxTweetCount {
                    self.stop()
                    self.isRequestingTweets = false
                }
            }
        }
    }

    func getMicropost() -> Tweet? {
        if tweets.count < ContinuityTweets.lowestTweetCount {
            fetchMicroposts()
        }
        if tweets.count != 0 {
            return tweets.removeFirst()
        } else {
            return nil
        }
    }

    func stop() {
        self.request?.stop()
    }
}
