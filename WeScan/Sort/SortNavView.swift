//
//  SortNavView.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/5.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

class SortNavView: UIView {
    
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
        self.addSubview(titleLabel)
        
        let leftBtn = UIButton()
        leftBtn.setTitle("back", for: .normal)
        leftBtn.setTitleColor(RGBColor(r: 80, g: 165, b: 195), for: .normal)
        leftBtn.frame = CGRect(x: 10, y: kNavHeight-44, width: 44, height: 44)
        leftBtn.addTarget(self, action: #selector(leftBtnClick), for: .touchUpInside)
        self.addSubview(leftBtn)
        
        let rightBtn = UIButton()
        rightBtn.setTitle("done", for: .normal)
        rightBtn.setTitleColor(RGBColor(r: 80, g: 165, b: 195), for: .normal)
        rightBtn.frame = CGRect(x: kScreenWidth-54, y: kNavHeight-44, width: 44, height: 44)
        rightBtn.addTarget(self, action: #selector(rightBtnClick), for: .touchUpInside)
        self.addSubview(rightBtn)
        
        let layer = CAGradientLayer()
        layer.frame = CGRect(x: 0, y: kNavHeight, width: kScreenWidth, height: 20)
        layer.colors = [UIColor.white.cgColor,UIColor.white.withAlphaComponent(0).cgColor]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 0, y: 1)
        layer.locations = [0,1]
        self.layer.addSublayer(layer)
    }
    @objc func leftBtnClick(){
        guard leftBtnComplete != nil else {return}
        leftBtnComplete!()
    }
    @objc func rightBtnClick(){
        guard rightBtnComplete != nil else {return}
        rightBtnComplete!()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
