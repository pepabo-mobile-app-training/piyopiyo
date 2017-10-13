//
//  APIClient.swift
//  piyopiyo
//
//  Created by shohei.ogata on 2017/10/03.
//  Copyright © 2017年 GMO Pepabo. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class APIClient {
    static private let baseUrl = "http://shizuna.xyz"
    
    static func request(endpoint: Endpoint, handler: @escaping (_ json: JSON) -> Void) {
        let method = endpoint.method()
        let url = fullURL(endpoint: endpoint)
        
        Alamofire.request(url, method: method).validate(statusCode: 200...299).responseJSON { response in
            switch response.result {
            case .success(let value):
                handler(JSON(value))
            case .failure(let error):
                handler([])
            }
        }
    }
    
    static private func fullURL(endpoint: Endpoint) -> String {
        return baseUrl + endpoint.path()
    }
    
    static func userFeedURL(_ userProfile: MicropostUserProfile) -> URL {
        return URL(string: "\(baseUrl)/users/\(userProfile.userID)")!
    }
}

enum Endpoint {
    case randomMicroposts
    case userProfile(String)
    case userFeed(String)
    
    func method() -> HTTPMethod {
        switch self {
        case .randomMicroposts: return .get
        case .userProfile: return .get
        case .userFeed: return .get
        }
    }
    
    func path() -> String {
        switch self {
        case .randomMicroposts: return "/api/random"
        case .userProfile(let value): return "/api/users/\(value)/profile"
        case .userFeed(let value): return "/api/users/\(value)"
        }
    }
}
