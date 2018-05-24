//
//  ViewController.swift
//  MVCDemo
//
//  Created by yangyouyong on 2018/5/23.
//  Copyright © 2018年 yangyouyong. All rights reserved.
//

import UIKit
import SnapKit
import Moya
import Kingfisher

class CarListController: UIViewController {

    var tableView: UITableView!
    
    var dataSource = [CarModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavBar()
        setupView()
        fetchNetwork()
    }

    func setupView() {
        
        setupTitleLabel(title: "Car List")
        
        tableView = {
            let tv = UITableView(frame: .zero, style: .plain)
            view.addSubview(tv)
            tv.snp.makeConstraints { (make) in
                make.top.equalTo(NavigationBar!.snp.bottom)
                make.left.right.bottom.equalTo(view)
            }
            tv.delegate = self
            tv.dataSource = self
            tv.register(CarCell.self, forCellReuseIdentifier: "CarCell")
            tv.separatorStyle = .none
            return tv
        }()
        
    }
    
    func fetchNetwork() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        BMWProvider.request(.carList("0")) { result in
            
            if case let .success(response) = result {
//                let stickCar = try? response.map(CarModel.self, atKeyPath: "data.stick_car")
                
                do {
//                    let resData = try response.map(ReponseData<CarModel>.self, atKeyPath: "data")
                    
                    let res = try response.map(ResObject<ReponseData<CarModel>>.self)
                    if let carList = res.data?.cars {
                        self.dataSource = carList
                        self.tableView.reloadData()
                    }
                    
                } catch let error {
                    print("map error: \(error)")
                }
            }
            
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CarListController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarCell", for: indexPath) as! CarCell
        let car = dataSource[indexPath.row]
        cell.configCell(car)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WHScale(98)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let car = dataSource[indexPath.row]
        let detailVC = CarDetailViewController()
        detailVC.vin = car.vin
        navigationController?.pushViewController(detailVC, animated: true)
        //
    }
    
}
