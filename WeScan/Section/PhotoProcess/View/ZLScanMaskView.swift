//
//  ZLScanMaskView.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/17.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

class ZLScanMaskView: UIView {
    
    private lazy var proLabel: UILabel = {
        let proLabel = UILabel()
        proLabel.text = "Restore ..."
        proLabel.textColor = globalColor
        proLabel.textAlignment = .center
        proLabel.font = UIFont.boldSystemFont(ofSize: 23)
        proLabel.frame = CGRect(x: 0, y: self.center.y-80, width: kScreenWidth, height: 22)
        return proLabel
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        alpha =  0.5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
