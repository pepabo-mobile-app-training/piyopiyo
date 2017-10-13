//
//  MicropostProtocol.swift
//  piyopiyo
//
//  Created by shohei.ogata on 2017/10/13.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import Foundation

protocol MicroContent {
    var userID: Int { get set }
    var content: String { get set }
}
