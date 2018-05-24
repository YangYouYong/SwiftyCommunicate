//
//  ResponseModel.swift
//  MVCDemo
//
//  Created by yangyouyong on 2018/5/24.
//  Copyright © 2018年 yangyouyong. All rights reserved.
//

import Foundation

struct ResObject<T: Codable>: Codable {
    
    var data: T?
    var ret: Int
    var detail: String?
}

struct ReponseData<T: Codable>: Codable {
    
    var cars: [T]?
    var pageNo: Int
    var stickCar: T?
    
    enum CodingKeys:String, CodingKey {
        case cars
        case pageNo = "page_no"
        case stickCar = "stick_car"
    }
}
