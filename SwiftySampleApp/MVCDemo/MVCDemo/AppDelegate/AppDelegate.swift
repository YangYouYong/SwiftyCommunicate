//
//  AppDelegate.swift
//  MVCDemo
//
//  Created by yangyouyong on 2018/5/23.
//  Copyright © 2018年 yangyouyong. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.makeKeyAndVisible()
        
        configNavigtor()
        
        return true
    }
    
    func configNavigtor() {
        let nav = UINavigationController(rootViewController: LoginViewController())
        nav.setNavigationBarHidden(true, animated: false)
        self.window!.rootViewController = nav
    }
}

