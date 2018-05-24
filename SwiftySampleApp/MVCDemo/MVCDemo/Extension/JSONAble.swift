//
//  JSONAble.swift
//  MVCDemo
//
//  Created by yangyouyong on 2018/5/23.
//  Copyright © 2018年 yangyouyong. All rights reserved.
//

import Foundation

// JSON -> Object
protocol JSONAble {
    static func fromJSON(_: [String: AnyObject]) -> Self
}

// Object -> JSON

protocol ReverseJSON {
    func reverseJSON() -> [String: AnyObject]
}

extension JSONAble {
    static func fromJSONArray(_ json: [AnyObject]) -> [Self] {
        return json.map { Self.fromJSON($0 as! [String : AnyObject]) }
    }
}


extension NSDictionary {
    
    func mapToObject<T: JSONAble>(_ classType: T.Type) -> T {
        return T.fromJSON(self as! [String : AnyObject])
    }
}

extension NSArray {
    func mapToObjectArray<T: JSONAble>(_ classType: T.Type) -> [T]? {
        
        if let dicts = self as? [NSDictionary] {
            return dicts.map {(j) in
                T.fromJSON(j as! [String : AnyObject])
            }
        }
        return nil
    }
    
    func reverseToJSON() -> [[String: AnyObject]] {
        return self.map({ (T) -> [String: AnyObject] in
            if T is ReverseJSON {
                return (T as! ReverseJSON).reverseJSON()
            }
            return ["": "" as AnyObject]
        })
    }
}
