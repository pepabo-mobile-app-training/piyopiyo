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
    static private var sample: HTTPRequest?
    static private let userDefaults = UserDefaults.standard
    static private let env = ProcessInfo.processInfo.environment

    static func authorize(presentFrom: UIViewController?) {
        guard let consumerKey = env["consumerKey"], let consumerSecret = env["consumerSecret"] else {
            return
        }

        if isAuthorized() {
            return
        }

        let swifter = Swifter(consumerKey: consumerKey, consumerSecret: consumerSecret)
        let callbackURL = URL(string: "piyopiyo://")!

        swifter.authorize(with: callbackURL, presentFrom: presentFrom, success: { (token, _) in
            guard let token = token else {
                return
            }
            userDefaults.set(token.key, forKey: "twitter_key")
            userDefaults.set(token.secret, forKey: "twitter_secret")
        }, failure: { (error) in
                // エラー処理
        })
    }

    static private func isAuthorized() -> Bool {
        let key = userDefaults.object(forKey: "twitter_key")
        let secret = userDefaults.object(forKey: "twitter_secret")

        if key != nil, secret != nil {
            return true
        } else {
            return false
        }
    }
}
