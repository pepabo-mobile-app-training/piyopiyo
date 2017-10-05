//
//  ContinuityMicroposts.swift
//  piyopiyo
//
//  Created by shohei.ogata on 2017/10/05.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import Foundation

class ContinuityMicroposts {
    private var microposts = [Micropost]()
    private var isRequestingMicroposts: Bool = false
    static let lowestMicropostCount = 5
    
    var count: Int {
        return microposts.count
    }
    
    func fetchMicroposts() {
        if !isRequestingMicroposts {
            isRequestingMicroposts = true
            Micropost.fetchRandomMicroposts { randomPosts in
                self.microposts += randomPosts
                self.isRequestingMicroposts = false
            }
        }
    }
    
    func getMicropost() -> Micropost? {
        if microposts.count < ContinuityMicroposts.lowestMicropostCount {
            self.fetchMicroposts()
        }
        if microposts.count != 0 {
            return self.microposts.removeFirst()
        } else {
            return nil
        }
    }
}
