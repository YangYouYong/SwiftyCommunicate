//
//  CarCell.swift
//  MVCDemo
//
//  Created by yangyouyong on 2018/5/24.
//  Copyright © 2018年 yangyouyong. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit

class CarCell: UITableViewCell {
    var titleLabel: UILabel!
    var vinLabel: UILabel!
    var vinContentLabel: UILabel!
    var dateLabel: UILabel!
    var carImageView: UIImageView!
    var separatorView: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        
        titleLabel = {
            let label = UILabel()
            contentView.addSubview(label)
            label.snp.makeConstraints({ (make) in
                make.top.equalTo(WHScale(27))
                make.left.equalTo(WHScale(20))
            })
            label.font = .systemFont(ofSize: WHScale(15))
            label.textColor = RGBSameColor(68)
            return label
        }()
        
        vinLabel = {
            let label = UILabel()
            contentView.addSubview(label)
            label.snp.makeConstraints({ (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(WHScale(9))
                make.left.equalTo(WHScale(20))
            })
            label.text = "VIN:"
            label.font = .systemFont(ofSize: WHScale(14))
            label.textColor = RGBColor(255, green: 145, blue: 0)
            return label
        }()
        
        vinContentLabel = {
            let label = UILabel()
            contentView.addSubview(label)
            label.snp.makeConstraints({ (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(WHScale(9))
                make.left.equalTo(vinLabel.snp.right).offset(WHScale(5))
            })
            label.font = .systemFont(ofSize: WHScale(14))
            label.textColor = RGBSameColor(199)
            return label
        }()
        
        dateLabel = {
            let label = UILabel()
            contentView.addSubview(label)
            label.snp.makeConstraints({ (make) in
                make.top.equalTo(vinLabel.snp.bottom).offset(WHScale(9))
                make.left.equalTo(WHScale(20))
            })
            label.font = .systemFont(ofSize: WHScale(13))
            label.textColor = RGBSameColor(199)
            return label
        }()
        
        carImageView = {
            let imgV = UIImageView()
            addSubview(imgV)
            imgV.snp.makeConstraints({ (make) in
                make.width.equalTo(WHScale(167))
                make.height.equalTo(WHScale(78))
                make.centerY.equalTo(self)
                make.right.equalTo(self.snp.right).offset(WHScale(30))
            })
            imgV.contentMode = .scaleAspectFit
            return imgV
        }()
        
        separatorView = {
            let v = UIView()
            contentView.addSubview(v)
            v.snp.makeConstraints({ (make) in
                make.right.left.bottom.equalTo(contentView)
                make.height.equalTo(1)
            })
            v.backgroundColor = RGBSameColor(230)
            return v
        }()
    }
    
    func configCell(_ model: CarModel) {
        titleLabel.text = model.brand + " " + model.model + " " + String(model.year)
        vinContentLabel.text = model.vin
        let destinyURLString: String = model.picUrl.hasPrefix("http") ? model.picUrl : ("https://" + model.picUrl)
        carImageView.kf.setImage(with: destinyURLString)
    }
}
