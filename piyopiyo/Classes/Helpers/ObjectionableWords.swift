//
//  ObjectionableWords.swift
//  piyopiyo
//
//  Created by 伊藤静那(Ito Shizuna) on 2017/11/25.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import Foundation

class ObjectionableWords {
    static func readTextFile() -> [String] {
        let fileName = "ObjectionableWords"

        guard let bundle = Bundle.main.path(forResource: fileName, ofType: "txt") else {
            return []
        }

        guard let content = try? String(contentsOfFile: bundle, encoding: .utf8) else {
            return []
        }

        let textArray = content.components(separatedBy: "\n")
        return textArray.dropLast().map { String(data: Data(base64Encoded: $0)!, encoding: .utf8)! }
    }
}
