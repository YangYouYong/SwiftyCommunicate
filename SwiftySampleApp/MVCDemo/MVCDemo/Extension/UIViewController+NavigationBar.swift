//
//  UIViewController+NavigationBar.swift
//  MVCDemo
//
//  Created by yangyouyong on 2018/5/24.
//  Copyright © 2018年 yangyouyong. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

extension UIViewController {
    
    private struct AssociatedKeys {
        static var NavigationBar = "navigationBar"
        static var NavigationBarTitleLabel = "navigationBarTitleLabel"
        static var NavigationBarBottomLine = "navigationBarBottomLine"
        static var NavigationBarLeftImage = "navigationBarLeftImage"
        static var NavigationBarRightImage = "navigationBarRightImage"
    }
    
    // MARK: Properties
    // MARK:
    
    var NavigationBar: UIView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.NavigationBar) as? UIView
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.NavigationBar,
                    newValue as UIView?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    var NavigationTitleLabel: UILabel? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.NavigationBarTitleLabel) as? UILabel
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.NavigationBarTitleLabel,
                    newValue as UILabel?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    var NavigationBottomLine: UIView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.NavigationBarBottomLine) as? UIView
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.NavigationBarBottomLine,
                    newValue as UIView?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    var NavigationBarLeftImage: UIButton? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.NavigationBarLeftImage) as? UIButton
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.NavigationBarLeftImage,
                    newValue as UIButton?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    var NavigationBarRightImage: UIButton? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.NavigationBarRightImage) as? UIButton
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.NavigationBarRightImage,
                    newValue as UIButton?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    // MARK: - Funcs
    // MARK:
    
    func setupNavBar() {
        if let _ = NavigationBar {
            
        }else{
            createNavigationBar()
        }
    }
    
    func setupTitleLabel() {
        if let _ = NavigationTitleLabel {
            
        } else {
            createNavigationBarTitleLabel()
        }
    }
    
    func setupTitleLabel(title: String?) {
        if let _ = NavigationTitleLabel {
            
        } else {
            createNavigationBarTitleLabel()
        }
        NavigationTitleLabel!.text = title
    }
    func hiddedBottomLine(hidden:Bool){
        if let _ = NavigationBottomLine {
        } else {
            createNavigationBarBottomLine()
        }
        NavigationBottomLine!.isHidden = hidden
    }
    func setupLeftImage(_ named:String,callback:@escaping ()->()){
        if let _ = NavigationBarLeftImage {
        } else {
            createNavigationBarLeftImage()
        }
        NavigationBarLeftImage!.setImage(UIImage(named:named), for: .normal)
        _ = NavigationBarLeftImage?.rx.controlEvent(.touchUpInside).subscribe(onNext: { (_) in
            callback()
        })
    }
    
    func setupRightImage(_ named:String?,callback:@escaping ()->()){
        if let _ = NavigationBarRightImage {
        } else {
            createNavigationBarRightImage()
        }
        if named != nil {
            
            NavigationBarRightImage!.setImage(UIImage(named:named!), for: .normal)
        }
        _ = NavigationBarRightImage!.rx.controlEvent(.touchUpInside).subscribe(onNext: { (_) in
            callback()
        })
    }
    // MARK: - Private Funcs
    // MARK:
    
    private func createNavigationBar(){
        let nvBar = UIView()
        nvBar.backgroundColor = HEXColor(0xFFFFFF)
        view.addSubview(nvBar)
        nvBar.snp.makeConstraints { (make) -> Void in
            make.top.left.right.equalTo(view)
            make.height.equalTo(BMWUIConstants.navigationBarHeight)
        }
        NavigationBar = nvBar
    }
    
    private func createNavigationBarTitleLabel() {
        setupNavBar()
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 1
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        NavigationBar!.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(NavigationBar!.snp.centerX)
            make.centerY.equalTo(NavigationBar!.snp.centerY).offset(WHScale(10))
            make.left.equalTo(NavigationBar!).offset(WHScale(46))
            make.right.equalTo(NavigationBar!).offset(WHScale(-46))
        }
        NavigationTitleLabel = titleLabel
    }
    
    private func createNavigationBarBottomLine() {
        setupNavBar()
        let line = UIView()
        line.backgroundColor = HEXColor(0xcccccc)
        line.isHidden = true
        NavigationBar!.addSubview(line)
        line.snp.makeConstraints { (make) -> Void in
            make.bottom.left.right.equalTo(NavigationBar!)
            make.height.equalTo(0.5)
        }
        NavigationBottomLine = line
    }
    
    private func createNavigationBarLeftImage() {
        setupNavBar()
        let btn = UIButton()
        NavigationBar!.addSubview(btn)
        btn.snp.makeConstraints { (make) -> Void in
            make.bottom.left.equalTo(NavigationBar!)
            make.width.height.equalTo(BMWUIConstants.navigationContentHeight);
        }
        NavigationBarLeftImage = btn
    }
    
    private func createNavigationBarRightImage() {
        setupNavBar()
        let btn = UIButton()
        NavigationBar!.addSubview(btn)
        btn.snp.makeConstraints { (make) -> Void in
            make.bottom.right.equalTo(NavigationBar!)
            make.width.height.equalTo(BMWUIConstants.navigationContentHeight);
        }
        NavigationBarRightImage = btn
    }
}
