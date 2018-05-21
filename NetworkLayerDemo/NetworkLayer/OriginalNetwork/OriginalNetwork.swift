//
//  OriginalNetwork.swift
//  NetworkLayer
//
//  Created by yangyouyong on 2018/5/21.
//  Copyright © 2018年 cpbee. All rights reserved.
//

import UIKit

class OriginalNetwork: NSObject {
    
    class func get() {
        
        let token = UserDefaults.standard.value(forKey: "access-token") as? String
        let userId = UserDefaults.standard.value(forKey: "user_id") as? String
        
        if let tokenString = token , let userIdString = userId{
            
            let url: URL = URL(string: "https://bmw.vechaindev.com/api/v1/users/\(userIdString)")!
            var request: URLRequest = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue(tokenString, forHTTPHeaderField: "access-token")
            
            let dataTask: URLSessionDataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
                var dict: [String: AnyObject]? = nil
                
                do {
                    dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as? [String: AnyObject]
                    
                } catch {
                    
                }
                
                print("PROFILE: \(String(describing: dict!))")
            }
            
            dataTask.resume()
        }
    }
    
    class func post() {
        
        let url: URL = URL(string: "https://bmw.vechaindev.com/api/v1/users/login")!
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let bodyString = "username=test&password=356a192b7913b04c54574d18c28d46e6395428ab"
        request.httpBody = bodyString.data(using: .utf8)
        
        let dataTask: URLSessionDataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            var dict: [String: AnyObject]? = nil
            
            do {
                dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as? [String: AnyObject]
                
            } catch {
                
            }
            
            let token = (response as? HTTPURLResponse)?.allHeaderFields["access-token"] as? String
            
            if let di = dict, let tokenString = token {
                let dataDict : [String: AnyObject] = di["data"] as! [String : AnyObject]
                let user_id = dataDict["id"] as! NSNumber
                UserDefaults.standard.set(tokenString, forKey: "access-token")
                UserDefaults.standard.set(user_id.stringValue, forKey: "user_id")
                UserDefaults.standard.synchronize()
            }
            
            print("\(String(describing: dict!))")
            
        }
        
        dataTask.resume()
    }
}
