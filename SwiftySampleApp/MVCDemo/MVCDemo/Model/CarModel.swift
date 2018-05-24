//
//  CarModel.swift
//  MVCDemo
//
//  Created by yangyouyong on 2018/5/24.
//  Copyright © 2018年 yangyouyong. All rights reserved.
//

import Foundation

struct CarModel: Codable {
    
    var model: String
    var brand: String
    var picUrl: String
    var vin: String
    var year: Int
    var mileageTime: Int?
    var mileage: Int?
    
    enum CodingKeys:String, CodingKey {
        
        case model
        case brand
        case picUrl = "pic_url"
        case vin
        case year
        case mileageTime = "mileage_time"
        case mileage
    }
    
}
