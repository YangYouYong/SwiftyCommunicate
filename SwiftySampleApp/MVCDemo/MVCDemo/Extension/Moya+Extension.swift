//
//  Moya+Extension.swift
//  MVCDemo
//
//  Created by yangyouyong on 2018/5/24.
//  Copyright © 2018年 yangyouyong. All rights reserved.
//

import Moya
import Result

func parseResult<T: Codable>(_ result: Result<Moya.Response, MoyaError>, modelType: T.Type, keypath: String? = nil) -> (T?, String?) {
    
    switch result {
    case .success(let response):
        
        return parseResponse(response,
                             modelType:T.self,
                             keypath: keypath)
        
    case .failure(let error):
        return (nil, "\(error)")
    }
    
}

func parseResponse<T: Codable>(_ response: Response, modelType: T.Type, keypath: String? = nil) -> (T?, String?) {
    
    do {
        let resData = try response.map(T.self, atKeyPath: keypath)
        return (resData, nil)
        
    } catch let error {
        
        print("parse error occur: \(error)")
        return (nil, "\(error)")
    }
}
