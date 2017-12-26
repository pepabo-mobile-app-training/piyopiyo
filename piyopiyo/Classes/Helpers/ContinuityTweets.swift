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

    private var swifter: Swifter
    private let consumerKey: String
    private let consumerSecret: String
    private let oauthToken: String
    private let oauthTokenSecret: String

    private let objectionableWords: [String]

    static let maxTweetCount = 50
    static let lowestTweetCount = 15

    var isAuthorized = true
    var isConnected = true

    init(consumerKey: String, consumerSecret: String, oauthToken: String, oauthTokenSecret: String, objectionableWords: [String]) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
        self.oauthToken = oauthToken
        self.oauthTokenSecret = oauthTokenSecret

        self.objectionableWords = objectionableWords

        self.swifter = Swifter(consumerKey: consumerKey, consumerSecret: consumerSecret, oauthToken: oauthToken, oauthTokenSecret: oauthTokenSecret)
        
        if self.oauthToken.isEmpty || self.oauthTokenSecret.isEmpty {
            isAuthorized = false
        }
    }

    var count: Int {
        return tweets.count
    }

    func fetchMicroContents() {
        if !isRequestingTweets {
            isRequestingTweets = true
            request = Tweet.fetchRandomTweets(swifter: swifter) { randomTweet, error in
                if let error = error as? SwifterError {
                    switch error.kind {
                    case .urlResponseError(status: 401, headers: _, errorCode: _):
                        self.isAuthorized = false
                    default:
                        break
                    }
                    self.isRequestingTweets = false
                } else if let error = error {
                    if error.localizedDescription == "The Internet connection appears to be offline." {
                        self.isConnected = false
                        self.isRequestingTweets = false
                    }
                }

                if let randomTweet = randomTweet {
                    if self.objectionableWords.index(of: randomTweet.content) == nil {
                        self.tweets.append(randomTweet)
                    }
                }

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
