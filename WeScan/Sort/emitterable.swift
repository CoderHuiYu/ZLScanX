//
//  emitterable.swift
//  粒子动画
//
//  Created by pc-570 on 2017/12/19.
//  Copyright © 2017年 pc-570. All rights reserved.
//

import UIKit

protocol emitterable {
    
}
//这里的 where Self : UIViewController 意思是对使用该效果必须继承自UIViewController
extension emitterable where Self : ZLPhotoEditorController {
    func start(_ point: CGPoint) {
        // 创建一个发射器
        let emitterLayer = CAEmitterLayer()
        //发射器的位置
        emitterLayer.position = CGPoint.init(x: point.x, y: point.y)
        //开启3维效果
        emitterLayer.preservesDepth = true
        
        // 创建一个装 CAEmitterCell 的数组
        var cells = [CAEmitterCell]()
        
        for i in 1...4 {
            //创建粒子
            let emitterCell = CAEmitterCell()
            
            // The number of emitted objects created very second
            emitterCell.birthRate = 3
            
            // 粒子发射速度 50~150
            emitterCell.velocity = 100
            emitterCell.velocityRange = 50
            
            //粒子垂直发射 发射角度为 45°~135° 。- 号表示 向上 发射
            emitterCell.emissionLongitude = CGFloat(-Double.pi/2)
            // 改这个可以改变发射的角度
            emitterCell.emissionRange = CGFloat(Double.pi/4)
            
            // 粒子存活时间 2~4s
            emitterCell.lifetime = 4
            emitterCell.lifetimeRange = 2
            
            // 粒子旋转角度 为 45°~135°
            emitterCell.spin = CGFloat(Double.pi/2)
            emitterCell.spinRange = CGFloat(Double.pi/4)
            
            // 设置粒子的图片 一定要转成.cgImage
//            emitterCell.contents = UIImage.init(named: "mine_\(i)")?.cgImage
            emitterCell.contents = UIImage(named: "mine_\(i)", in: Bundle.init(for: self.classForCoder), compatibleWith: nil)?.cgImage
            
            cells.append(emitterCell)
        }
        
        emitterLayer.emitterCells = cells
        
        coverView.layer.addSublayer(emitterLayer)
    }
    
    func stop() {
        coverView.layer.sublayers?.filter({$0.isKind(of: CAEmitterLayer.self)}).first?.removeFromSuperlayer()
    }
}
