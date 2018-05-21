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

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var requestType:[String] = ["Original Network",
                                "Alamofire",
                                "Moya",
                                "RxMoya"]
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        OriginalNetwork.post()
        
        OriginalNetwork.get()
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
            gitHubProvider.request(.zen) { result in
                var message = "Couldn't access API"
                if case let .success(response) = result {
                    let jsonString = try? response.mapString()
                    message = jsonString ?? message
                }
                
                print("Zen: \(message)")
            }
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

