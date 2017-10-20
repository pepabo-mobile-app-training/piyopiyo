//
//  UserProfile.swift
//  piyopiyo
//
//  Created by shohei.ogata on 2017/10/13.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import Foundation

protocol UserProfile {
    var userID: String { get set }
    var name: String { get set }
    var avatarURL: URL? { get set }
}
