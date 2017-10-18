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

    func authorize(presentFrom: UIViewController?, handle: @escaping (_ result: Bool) -> Void) {
        if isAuthorized() {
            handle(true)
            return
        }

        let swifter = Swifter(consumerKey: consumerKey, consumerSecret: consumerSecret)

        swifter.authorize(with: callbackURL, presentFrom: presentFrom, success: { (token, _) in
            guard let token = token else {
                handle(false)
                return
            }
            self.userDefaults.set(token.key, forKey: "twitter_key")
            self.userDefaults.set(token.secret, forKey: "twitter_secret")
            handle(true)
        }, failure: { (error) in
            handle(false)
        })
    }

    private func isAuthorized() -> Bool {
        let key = userDefaults.object(forKey: "twitter_key")
        let secret = userDefaults.object(forKey: "twitter_secret")

        return key != nil && secret != nil
    }
}
