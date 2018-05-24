//
//  UIViewController+Loading.swift
//  MVCDemo
//
//  Created by yangyouyong on 2018/5/24.
//  Copyright © 2018年 yangyouyong. All rights reserved.
//

import UIKit
import MBProgressHUD

// MARK: - Loading
extension UIViewController {
    
    private struct AssociatedKeys {
        static var privateHUD = "privateHUD"
    }
    
    func showLoading() {
        
        if privateHUD == nil {
            let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
            progressHUD.backgroundColor = HEXAColor(0x0, alpha: 0.1)
            progressHUD.mode = .indeterminate
            progressHUD.removeFromSuperViewOnHide = true
            progressHUD.contentColor = .black
            progressHUD.bezelView.color = .white
            progressHUD.label.textColor = .black
            progressHUD.delegate = self
            progressHUD.show(animated: true)
            privateHUD = progressHUD
        }
    }
    
    func dismissLoading() {
        MBProgressHUD.hide(for: view, animated: true)
        privateHUD = nil
    }
    
    var privateHUD : MBProgressHUD? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.privateHUD) as? MBProgressHUD
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.privateHUD,
                newValue as MBProgressHUD?,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}

extension UIViewController: MBProgressHUDDelegate {
    public func hudWasHidden(_ hud: MBProgressHUD) {
        privateHUD = nil
    }
}
