//
//  KingFisher+Extension.swift
//  MVCDemo
//
//  Created by yangyouyong on 2018/5/24.
//  Copyright © 2018年 yangyouyong. All rights reserved.
//

import Kingfisher

extension String: Resource {
    
    public var cacheKey: String { return self }
    
    public var downloadURL: URL {
        if let url = URL(string: self) {
            return url
        }
        return URL(string: "")!
    }
}
