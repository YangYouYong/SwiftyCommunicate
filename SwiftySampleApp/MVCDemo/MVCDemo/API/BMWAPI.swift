//
//  BMWAPI.swift
//  MVCDemo
//
//  Created by yangyouyong on 2018/5/23.
//  Copyright © 2018年 yangyouyong. All rights reserved.
//

import Foundation
import Moya

var BMWProvider = MoyaProvider<BMW>()

// MARK: - Provider support

private extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}

public enum BMW {
    case login(String, String)
    case userProfile(String)
    case carList(String)
    case carDetail(String)
}

extension BMW: TargetType {
    public var baseURL: URL { return URL(string: "https://bmw.vechaindev.com")! }
    public var path: String {
        switch self {
        case .login(_ , _):
            return "/api/v1/users/login"
        case .userProfile(let name):
            return "/api/v1/users/\(name.urlEscaped)"
        case .carList(_):
            return "/api/v1/dashboard/cars"
        case .carDetail(let vin):
            return "/api/v1/cars/\(vin)/profile"
        }
        
        
    }
    public var method: Moya.Method {
        switch self {
        case .login(_, _):
            return .post
        default:
            return .get
        }
    }
    public var task: Task {
        switch self {
        case .login(let username, let password):
            return .requestCustomJSONEncodable(["username": username, "password": password], encoder:JSONEncoder())
        case .carList(let page):
            return .requestParameters(parameters: ["page": page,"page_size":"10"], encoding: URLEncoding())
        default:
            return .requestPlain
        }
    }
    public var validationType: ValidationType {
        switch self {
        case .login(_, _),
             .userProfile(_):
            return .successCodes
        default:
            return .none
        }
    }
    
    public var sampleData: Data {
        switch self {
        default:
            return "Half measures are as bad as nothing at all.".data(using: String.Encoding.utf8)!
        }
    }
    
    public var headers: [String: String]? {
        
        switch self {
        case .login:
            
            return nil
        default:
            if let accessToken = UserDefaults.standard.value(forKey:"accessToken") as? String {
                return ["access-token": accessToken]
            }
            return nil
        }
    }
}
