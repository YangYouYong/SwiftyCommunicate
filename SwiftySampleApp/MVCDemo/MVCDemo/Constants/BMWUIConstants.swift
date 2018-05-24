//
//  UIConstants.swift
//  MVCDemo
//
//  Created by yangyouyong on 2018/5/23.
//  Copyright © 2018年 yangyouyong. All rights reserved.
//

import UIKit

struct BMWUIConstants {
    
    static let isPhone: Bool = UIDevice.current.userInterfaceIdiom == .phone
    static let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
    static let safeAreaHeight: CGFloat = BMWUIConstants.isIphoneX ? 34 : 0
    static var statusBarH: CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    static var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    static var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    static var screenScale: CGFloat {
        return UIScreen.main.scale
    }
    static var screenRatio: CGFloat {
        return screenWidth / screenHeight
    }
    
    static let statusBarHeight = BMWUIConstants.isIphoneX ? WHScale(44) : WHScale(20)
    static let navigationBarHeight = WHScale(44) + statusBarHeight
    static let navigationContentHeight = WHScale(44)
    static let statusBarHegiht = BMWUIConstants.statusBarH
    static let tabBarHeight = WHScale(49) + BMWUIConstants.safeAreaHeight
    
    static var isIphone4: Bool {
        return UIScreen.main.bounds.size.equalTo(CGSize(width: 320, height: 480))
    }
    
    static var isIphone5: Bool {
        return UIScreen.main.bounds.size.equalTo(CGSize(width: 320, height: 568))
    }
    
    static var isIphoneX: Bool {
        return UIScreen.main.bounds.size.height == 812
    }
    
}

func WHScale(_ width: CGFloat) -> CGFloat {
    return width * BMWUIConstants.screenWidth / 375.0
}

func RGBSameColor(_ red: Int , alpha: CGFloat = 1.0) -> UIColor {
    return RGBColor(red, green: red, blue: red, alpha: alpha)
}

func RGBColor(_ rgbTuple: (Int,Int,Int), alpha: CGFloat = 1.0) -> UIColor {
    let (red, green, blue) = rgbTuple
    return RGBColor(red, green: green, blue: blue)
}

func RGBColor(_ red: Int, green: Int, blue: Int , alpha: CGFloat = 1.0) -> UIColor {
    return UIColor(
        red: CGFloat(red)/255.0,
        green: CGFloat(green)/255.0,
        blue: CGFloat(blue)/255.0,
        alpha: alpha)
}

// 十六进制颜色值
func HEXColor(_ rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16)/255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8)/255.0,
        blue: CGFloat(rgbValue & 0x0000FF)/255.0,
        alpha: 1.0)
}

func HEXAColor(_ rgbValue: UInt, alpha: CGFloat) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16)/255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8)/255.0,
        blue: CGFloat(rgbValue & 0x0000FF)/255.0,
        alpha: CGFloat(alpha))
}
