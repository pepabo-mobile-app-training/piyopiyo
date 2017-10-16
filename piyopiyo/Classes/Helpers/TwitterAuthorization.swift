//
//  TwitterAuthorization.swift
//  piyopiyo
//
//  Created by shizuna.ito on 2017/10/13.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import Foundation
import UIKit
import SwifteriOS
import Alamofire

class TwitterAuthorization {
    private let userDefaults = UserDefaults.standard
    private let consumerKey: String
    private let consumerSecret: String
    private let callbackURL = URL(string: "piyopiyo://")!

    init(consumerKey: String?, consumerSecret: String?) throws {
        guard let consumerKey = consumerKey, let consumerSecret = consumerSecret else {
            throw TwitterClientError.missingEnvironmentKeys
        }

        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
    }

    func authorize(presentFrom: UIViewController?) -> Bool {
        if isAuthorized() {
            return false
        }

        let swifter = Swifter(consumerKey: consumerKey, consumerSecret: consumerSecret)

        swifter.authorize(with: callbackURL, presentFrom: presentFrom, success: { (token, _) in
            guard let token = token else {
                return
            }
            self.userDefaults.set(token.key, forKey: "twitter_key")
            self.userDefaults.set(token.secret, forKey: "twitter_secret")
        }, failure: { (error) in
            // エラー処理
        })

        return true
    }

    private func isAuthorized() -> Bool {
        let key = userDefaults.object(forKey: "twitter_key")
        let secret = userDefaults.object(forKey: "twitter_secret")

        return key != nil && secret != nil
    }
}
