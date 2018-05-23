//
//  ViewController.swift
//  NetworkLayer
//
//  Created by yangyouyong on 2018/5/21.
//  Copyright © 2018年 cpbee. All rights reserved.
//

import UIKit
import Moya
import Alamofire
import RxSwift

import RxCocoa
import Action
import NSObject_Rx

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var requestCommand: Action<(String, String), Void>?
    private var provider = MoyaProvider<BMW>()
    
    let responseObject = BehaviorRelay<Any?>(value: nil)
    
    var rxprovider: Networking = Networking.newDefaultNetworking()
    
    var requestType:[String] = ["Original Network",
                                "Alamofire",
                                "Moya",
                                "RxMoya",
                                "开挂的RxMoya"]
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        OriginalNetwork.post()
        
        OriginalNetwork.get()
        
        requestCommand = Action(workFactory: { (username, password) in

            return Observable.create({[unowned self] (observer) -> Disposable in

                self.rxprovider
                    .request(.login("jackwu","fa39d424037d94cb4efcbfd5e4b05b9e6a8bb91c"))
                    .filterSuccessfulStatusCodes()
                    .mapJSON()
                    .bind(to: self.responseObject)
                    .disposed(by: self.rx.disposeBag)

                observer.onCompleted()
                return Disposables.create()
            })
        })
        
        _ = responseObject.asObservable().subscribe(onNext: { (obj) in
            print("resp:\(String(describing: obj))")
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func switchNetworkingType(_ type: Int){
        if type == 0 {
            OriginalNetwork.post()
            OriginalNetwork.get()
            return
        }
        
        if type == 1 {
            
            Alamofire.request("https://httpbin.org/post", method: .post).validate().responseJSON { (resJson) in
                print("Alamofire Json: \(resJson)")
            }
            
            let parameters = ["username": "username"]
            Alamofire.request("https://httpbin.org/post", method: .post, parameters: parameters, encoding: URLEncoding.httpBody) .validate().responseJSON { (resJson) in
                print("Alamofire Response: \(resJson)")
                // mapper & serializer
            }
            
            return
        }
        
        if type == 2 {
//            gitHubProvider.request(.zen) { result in
//                var message = "Couldn't access API"
//                if case let .success(response) = result {
//                    let jsonString = try? response.mapString()
//                    message = jsonString ?? message
//                }
//
//                print("Zen: \(message)")
//            }
        }
        
        if type == 3 {
            
            _ = provider.rx
                .request(.login("jackwu","fa39d424037d94cb4efcbfd5e4b05b9e6a8bb91c"))
                .filterSuccessfulStatusCodes()
                .mapJSON()
                .subscribe { event in
                    
                    // serializer
                switch event {
                    case .success(let response):
                        print("response:\(response)")
                    case .error(let error):
                        print("errored: \(error)")
                }
            }
            
            
            // 20007
            _ = provider.rx
                .request(.userProfile("20007"))
                .filterSuccessfulStatusCodes()
                .mapJSON()
                .subscribe { event in
                    
                    // serializer
                    switch event {
                    case .success(let response):
                        print("response:\(response)")
                    case .error(let error):
                        print("errored: \(error)")
                    }
            }
        }
        
        if type == 4 {
            
            _ = requestCommand!.execute(("jackwu", "fa39d424037d94cb4efcbfd5e4b05b9e6a8bb91c"))
            
            print("type 4")
            
        }
    }

}

extension ViewController: UITableViewDelegate,
UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.requestType.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = self.requestType[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switchNetworkingType(indexPath.row)
    }
}

