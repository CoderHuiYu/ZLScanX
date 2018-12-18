//
//  ZLSortNavgationView.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/17.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

class ZLSortNavgationView: UIView {

    var leftBtnComplete: (()->())?
    var rightBtnComplete: (()->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let titleLabel = UILabel()
        titleLabel.text = "Sort"
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.frame = CGRect(x: 0, y: kNavHeight - 44, width: kScreenWidth, height: 44)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        
        let leftBtn = UIButton()
        leftBtn.setTitle("back", for: .normal)
        leftBtn.setTitleColor(RGBColor(r: 80, g: 165, b: 195), for: .normal)
        leftBtn.frame = CGRect(x: 10, y: kNavHeight-44, width: 44, height: 44)
        leftBtn.addTarget(self, action: #selector(leftBtnClick), for: .touchUpInside)
        addSubview(leftBtn)
        
        let rightBtn = UIButton()
        rightBtn.setTitle("done", for: .normal)
        rightBtn.setTitleColor(RGBColor(r: 80, g: 165, b: 195), for: .normal)
        rightBtn.frame = CGRect(x: kScreenWidth-54, y: kNavHeight-44, width: 44, height: 44)
        rightBtn.addTarget(self, action: #selector(rightBtnClick), for: .touchUpInside)
        addSubview(rightBtn)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: kNavHeight, width: kScreenWidth, height: 20)
        gradientLayer.colors = [UIColor.white.cgColor,UIColor.white.withAlphaComponent(0).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.locations = [0,1]
        layer.addSublayer(gradientLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc private func leftBtnClick(){
        guard let leftBtnComplete = leftBtnComplete else { return }
        leftBtnComplete()
    }
    
    @objc private func rightBtnClick(){
        guard let rightBtnComplete = rightBtnComplete else { return }
        rightBtnComplete()
    }
}
