//
//  LoginViewController.swift
//  MVCDemo
//
//  Created by yangyouyong on 2018/5/23.
//  Copyright © 2018年 yangyouyong. All rights reserved.
//

import UIKit
import SnapKit
import CryptoSwift

class LoginViewController: UIViewController {

    var bgImageView: UIImageView!
    var usernameTextField: UITextField!
    var passwordTextField: UITextField!
    var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Login"
        
        setupNavBar()
        setupView()
    
        // Do any additional setup after loading the view.
    }

    func setupView() {
        
        view.backgroundColor = .white
        
        bgImageView = {
            let iv = UIImageView()
            view.addSubview(iv)
            iv.snp.makeConstraints({ (make) in
                make.edges.equalTo(view)
            })
            iv.image = UIImage(named: "pic_login")
            iv.isUserInteractionEnabled = true
            return iv
        }()
        
        usernameTextField = {
            let tf = UITextField()
            bgImageView.addSubview(tf)
            tf.snp.makeConstraints({ (make) in
                make.left.equalTo(WHScale(20))
                make.top.equalTo(WHScale(120))
                make.right.equalTo(WHScale(-20))
                make.height.equalTo(WHScale(40))
            })
            tf.placeholder = "username"
            tf.textColor = RGBSameColor(0)
            tf.text = "test"
            tf.font = .systemFont(ofSize: WHScale(14))
            return tf
        }()
        
        passwordTextField = {
            let tf = UITextField()
            bgImageView.addSubview(tf)
            tf.snp.makeConstraints({ (make) in
                make.left.right.height.equalTo(usernameTextField)
                make.top.equalTo(usernameTextField.snp.bottom).offset(WHScale(20))
            })
            tf.placeholder = "password"
            tf.text = "BMW2018"
            tf.isSecureTextEntry = true
            tf.textColor = RGBSameColor(0)
            tf.font = .systemFont(ofSize: WHScale(14))
            return tf
        }()
        
        loginBtn = {
            let btn = UIButton()
            bgImageView.addSubview(btn)
            btn.snp.makeConstraints({ (make) in
                make.left.right.height.equalTo(usernameTextField)
                make.top.equalTo(passwordTextField.snp.bottom).offset(WHScale(20))
            })
            btn.backgroundColor = RGBColor(146, green: 162, blue: 189)
            btn.setTitle("SIGN IN", for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.addTarget(self, action: #selector(login), for: .touchUpInside)
            return btn
        }()
    }
    
    @objc func login(){
        if let username = usernameTextField.text, let password = passwordTextField.text {
            let encoredPassword = password.sha1()
            
            BMWProvider.request(.login(username,encoredPassword)) { result in
                var message = "Couldn't access API"
                if case let .success(response) = result {
                    let jsonString = try? response.mapString()
                    message = jsonString ?? message
                    
                    if let headerFields = response.response?.allHeaderFields ,
                        let accessToken = headerFields["access-token"] {
                        UserDefaults.standard.set(accessToken, forKey: "accessToken")
                        UserDefaults.standard.synchronize()
                        
                        self.navigationController?.pushViewController(CarListController(), animated: true)
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
