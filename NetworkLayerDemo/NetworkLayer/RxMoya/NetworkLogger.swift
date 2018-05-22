//
//  NetworkLogger.swift
//  NetworkLayer
//
//  Created by yangyouyong on 2018/5/22.
//  Copyright © 2018年 cpbee. All rights reserved.
//

import UIKit
import Moya
import Result

// MARK: - NetworkLogger
class NetworkLogger: PluginType {
    
    typealias Comparison = (TargetType) -> Bool
    
    let whitelist: Comparison
    let blacklist: Comparison
    
    init(whitelist: @escaping Comparison = { _ -> Bool in return true }, blacklist: @escaping Comparison = { _ -> Bool in  return true }) {
        self.whitelist = whitelist
        self.blacklist = blacklist
    }
    
    func willSend(_ request: RequestType, target: TargetType) {
        guard blacklist(target) == false else { return }
        logger.log(message: LoggerFormatter.cURLCommandFromURLRequest(request: request.request! as NSURLRequest))
    }
    
    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        
        guard blacklist(target) == false else { return }
        
        switch result {
        case .success(let response):
            if 200..<400 ~= (response.statusCode ) && whitelist(target) == false {
                // If the status code is OK, and if it's not in our whitelist, then don't worry about logging its response body.
                logger.log(message:"Received response(\(response.statusCode )) from \(response.response?.url?.absoluteString ?? String()).")
            }
        case .failure(let error):
            // Otherwise, log everything.
            logger.log(message:"Received networking error: \(error)")
        }
    }
}

func logPath() -> NSURL {
    let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    return (docs as NSURL).appendingPathComponent("logger.txt")! as NSURL
}
