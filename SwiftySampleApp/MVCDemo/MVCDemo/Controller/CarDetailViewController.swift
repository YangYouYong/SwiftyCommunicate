//
//  CarDetailViewController.swift
//  MVCDemo
//
//  Created by yangyouyong on 2018/5/24.
//  Copyright © 2018年 yangyouyong. All rights reserved.
//

import UIKit

import SnapKit
import Moya
import Kingfisher
import Result
import MBProgressHUD

class CarDetailViewController: UIViewController {

    public var vin: String?
    
    var mileageLabel: UILabel!
    var carImageView: UIImageView!
    var vinLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavBar()
        setupView()
        
        fetchCarDetail()
    }

    func setupView() {
        
        setupTitleLabel(title: "Car Detail")
        setupLeftImage("icon_back", callback: { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        })
        
        mileageLabel = {
            let label = UILabel()
            view.addSubview(label)
            label.snp.makeConstraints({ (make) in
                make.top.equalTo(NavigationBar!.snp.bottom).offset(WHScale(53))
                make.right.equalTo(WHScale(20))
            })
            label.font = .systemFont(ofSize: WHScale(15))
            label.textColor = RGBColor((254, 203, 0))
            return label
        }()
        
        carImageView = {
            let imgV = UIImageView()
            view.addSubview(imgV)
            imgV.snp.makeConstraints({ (make) in
                make.centerX.equalTo(view)
                make.top.equalTo(NavigationBar!.snp.bottom).offset(WHScale(87))
                make.width.lessThanOrEqualTo(WHScale(288))
                make.height.lessThanOrEqualTo(WHScale(134))
            })
            imgV.contentMode = .scaleAspectFit
            return imgV
        }()
        
        vinLabel = {
            let label = UILabel()
            view.addSubview(label)
            label.snp.makeConstraints({ (make) in
                make.top.equalTo(NavigationBar!.snp.bottom).offset(WHScale(200))
                make.centerX.equalTo(view)
            })
            label.font = .systemFont(ofSize: WHScale(15))
            label.textColor = .black
            return label
        }()
    }
    
    func fetchCarDetail() {
        
        guard let _ = vin else {
            return
        }
        
        //TODO: show loading
        showLoading()
        BMWProvider.request(.carDetail(vin!)) { result in
            
            self.dismissLoading()
            
            let (model, error) = parseResult(result,
                                      modelType:CarModel.self,
                                       keypath: "data.car_profile")
            
            if let errorString = error {
                print(errorString)
                return
            }
            
            self.updateView(model!)
        }
    }
    
    func updateView(_ model: CarModel) {
        
        vinLabel.text = "VIN: " + model.vin
        let destinyURLString: String = model.picUrl.hasPrefix("http") ? model.picUrl : ("https://" + model.picUrl)
        carImageView.kf.setImage(with: destinyURLString)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
