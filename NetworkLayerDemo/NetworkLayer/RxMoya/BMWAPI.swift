//
//  BMWAPI.swift
//  NetworkLayer
//
//  Created by yangyouyong on 2018/5/22.
//  Copyright © 2018年 cpbee. All rights reserved.
//

import UIKit

import Moya

// MARK: - Provider setup

private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data // fallback to original data if it can't be serialized.
    }
}

var BMWProvider = MoyaProvider<BMW>(plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)])

// MARK: - Provider support

private extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}

public enum BMW {
    case login(String, String)
    case userProfile(String)
}

extension BMW: TargetType {
    public var baseURL: URL { return URL(string: "https://bmw.vechaindev.com")! }
    public var path: String {
        switch self {
        case .login(_ , _):
            return "/api/v1/users/login"
        case .userProfile(let name):
            return "/api/v1/users/\(name.urlEscaped)"
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
        default:
            return .requestPlain
        }
    }
    public var validationType: ValidationType {
        switch self {
        case .login(_, _),
             .userProfile(_):
            return .successCodes
//        default:
//            return .none
        }
    }
    public var sampleData: Data {
        switch self {
        default:
            return "Half measures are as bad as nothing at all.".data(using: String.Encoding.utf8)!
        }
    }
    public var headers: [String: String]? {
        return nil
    }
}
