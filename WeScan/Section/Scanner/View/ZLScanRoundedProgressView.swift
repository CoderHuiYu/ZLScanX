//
//  ZLScanRoundedProgressView.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/17.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

struct ZLScanProgressProperty{
    var width:CGFloat
    var trackColor:UIColor
    var progressColor :UIColor
    var progressStart:CGFloat
    var progressEnd:CGFloat
    
    init(width:CGFloat,progressEnd:CGFloat,progressColor:UIColor) {
        self.width = width
        self.progressEnd = progressEnd
        self.progressColor = progressColor
        trackColor = UIColor.clear
        progressStart = 0.0
    }
    
    init() {
        width = 5
        trackColor = UIColor.clear
        progressColor = UIColor.green
        progressStart = 0.0
        progressEnd = 0.0
    }
}



class ZLScanRoundedProgressView: UIView {
    
    var progressProperty = ZLScanProgressProperty()
    private let progressLayer = CAShapeLayer()
    
    init(propressProperty:ZLScanProgressProperty,frame:CGRect) {
        self.progressProperty = propressProperty
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(ovalIn: bounds).cgPath
        
        let trackLayer = CAShapeLayer()
        trackLayer.frame = bounds
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = progressProperty.trackColor.cgColor
        trackLayer.lineWidth = progressProperty.width
        trackLayer.path = path
        layer.addSublayer(trackLayer)
        
        progressLayer.frame = bounds
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressProperty.progressColor.cgColor
        progressLayer.lineWidth = progressProperty.width
        progressLayer.path = path
        progressLayer.strokeStart = progressProperty.progressStart
        progressLayer.strokeEnd = progressProperty.progressEnd
        layer.addSublayer(progressLayer)
        
    }
    
    func setProgress(progress:CGFloat,time:CFTimeInterval,animate:Bool) {
        CATransaction.begin()
        CATransaction.setDisableActions(!animate)
        CATransaction.setAnimationDuration(time)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))
        progressLayer.strokeEnd = progress
        CATransaction.commit()
        
    }
}

