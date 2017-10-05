//
//  ContinuityMicroposts.swift
//  piyopiyo
//
//  Created by shohei.ogata on 2017/10/05.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import Foundation

class ContinuityMicroposts{
    var microposts = [Micropost]()
    static let lowestMicropostCount = 5
    
    func getMicropost(handler: @escaping ((Micropost) -> Void)) {
        if( microposts.count < ContinuityMicroposts.lowestMicropostCount ) {
            Micropost.fetchRandomMicroposts() { randomPosts in
                self.microposts += randomPosts
                handler(self.microposts.removeFirst())
            }
        }
        else{
            handler(self.microposts.removeFirst())
        }
    }
}

