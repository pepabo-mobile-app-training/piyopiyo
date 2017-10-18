//
//  ContinuityTweets.swift
//  piyopiyo
//
//  Created by shizuna.ito on 2017/10/17.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import Foundation
import SwifteriOS

class ContinuityTweets: ContinuityMicroContents {
    private var tweets = [Tweet]()
    private var isRequestingTweets: Bool = false
    private var request: HTTPRequest?

    private let consumerKey: String
    private let consumerSecret: String
    private let oauthToken: String
    private let oauthTokenSecret: String

    static let maxTweetCount = 50
    static let lowestTweetCount = 5

    init(consumerKey: String, consumerSecret: String, oauthToken: String, oauthTokenSecret: String) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
        self.oauthToken = oauthToken
        self.oauthTokenSecret = oauthTokenSecret
    }

    var count: Int {
        return tweets.count
    }

    func fetchMicroContents() {
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

    func getMicroContent() -> MicroContent? {
        if tweets.count < ContinuityTweets.lowestTweetCount {
            fetchMicroContents()
        }
        if tweets.count != 0 {
            return tweets.removeFirst()
        } else {
            return nil
        }
    }

    private func stop() {
        self.request?.stop()
    }
}
