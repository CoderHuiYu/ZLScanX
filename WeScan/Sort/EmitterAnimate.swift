//
//  EmitterAnimate.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/4.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import Foundation

protocol EmitterAnimate {
    
}
extension EmitterAnimate where Self : ZLPhotoEditorController {
    //MARK: -- startAnimate
    func start(_ point: CGPoint) {
        let emitterLayer = CAEmitterLayer()
        //start point
        emitterLayer.position = CGPoint.init(x: point.x, y: point.y)
        //Turn on 3D effects
        emitterLayer.preservesDepth = true
        
        // Creat CAEmitterCell Array
        var cells = [CAEmitterCell]()
        
        //Creat particle
        let emitterCell = CAEmitterCell()
        
        // The number of emitted objects created very second
        emitterCell.birthRate = 3
        
        emitterCell.velocity = 100
        emitterCell.velocityRange = 50
        
        emitterCell.emissionLongitude = CGFloat(-Double.pi/2)
        emitterCell.emissionRange = CGFloat(Double.pi/4)
        
        // LifeTime of particle
        emitterCell.lifetime = 4
        emitterCell.lifetimeRange = 2
        
        // Rotation angle 45°~135°
        emitterCell.spin = CGFloat(Double.pi/2)
        emitterCell.spinRange = CGFloat(Double.pi/4)
        
        // Cell's image must convert -> cgImage
        emitterCell.contents = UIImage(named: "icon-test", in: Bundle.init(for: self.classForCoder), compatibleWith: nil)?.cgImage
        
        cells.append(emitterCell)
        cells.append(emitterCell)
        cells.append(emitterCell)
        cells.append(emitterCell)
        cells.append(emitterCell)
        cells.append(emitterCell)
        cells.append(emitterCell)
        
        emitterLayer.emitterCells = cells
        
        coverView.layer.addSublayer(emitterLayer)
    }
    //MARK: -- stopAnimate
    func stop() {
        coverView.layer.sublayers?.filter({$0.isKind(of: CAEmitterLayer.self)}).first?.removeFromSuperlayer()
    }
}
