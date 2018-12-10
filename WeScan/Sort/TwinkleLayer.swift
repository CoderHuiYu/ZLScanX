//
//  TwinkleLayer.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/9.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

class TwinkleLayer: CAEmitterLayer {

    override init() {
        super.init()
        creatCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func creatCell(){
        let image = UIImage(named: "icon-test", in: Bundle.init(for: self.classForCoder), compatibleWith: nil)
        let array = [CAEmitterCell()]
        for (_,cell) in array.enumerated(){
            cell.birthRate = 8
            cell.lifetime = 1.25
            cell.lifetimeRange = 2
//            cell.emissionRange = CGFloat.pi / 4
            cell.emissionLongitude = CGFloat(-Double.pi/2)
            cell.emissionRange = CGFloat(Double.pi/4)
            cell.spin = CGFloat(Double.pi/2)
            cell.spinRange = CGFloat(Double.pi/4)
            cell.velocity = 2
            cell.velocityRange = 18
            cell.scale = 0.65
            cell.scaleRange = 0.7
            cell.scaleSpeed = 0.6
//            cell.spin = 0.9
//            cell.spinRange = CGFloat.pi/
            cell.color = UIColor(white: 1, alpha: 3).cgColor
            cell.alphaSpeed = -0.8
            cell.contents = image?.cgImage
            cell.magnificationFilter = "linear"
            cell.minificationFilter = "trilinear"
            cell.isEnabled = true
        }
        self.emitterCells = array
        self.emitterPosition = CGPoint(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5)
        self.emitterSize = CGSize(width: 1, height: 1)
        self.emitterMode = CAEmitterLayerEmitterMode(rawValue: "surface")
        self.emitterShape = CAEmitterLayerEmitterShape(rawValue: "circle")
        self.renderMode = CAEmitterLayerRenderMode(rawValue: "unordered")
    }
}
extension UIView{
    func twinkle(){
        var twinkles = [TwinkleLayer]()
        let upperBound: UInt32 = 10
        let lowerBound: UInt32 = 5
        let count = UInt8(arc4random_uniform(upperBound + lowerBound))
        for i in 0 ..< count + 10{
            let layer = TwinkleLayer()
            let x = CGFloat(arc4random_uniform(UInt32(self.layer.bounds.size.width)))
            let y = CGFloat(arc4random_uniform(UInt32(self.layer.bounds.size.height)))
            layer.position = CGPoint(x: x, y: y)
            layer.opacity = 0
            twinkles.append(layer)
            self.layer.addSublayer(layer)
//            layer.positionAnimate()
//            layer.rotationAnimation()
            layer.fadeInOutAnimation(CACurrentMediaTime() + CFTimeInterval(0.05 * Double(i)))
        }
        twinkles.removeAll()
    }
}
extension TwinkleLayer{
    func positionAnimate(){
        CATransaction.begin()
        let keyFrameAnimate = CAKeyframeAnimation(keyPath: "position")
        keyFrameAnimate.duration = 0.3
        keyFrameAnimate.isAdditive = true
        keyFrameAnimate.repeatCount = MAXFLOAT
        keyFrameAnimate.isRemovedOnCompletion = false
        keyFrameAnimate.beginTime = CFTimeInterval(arc4random_uniform(1000 + 1)) * 0.2 * 0.25
        let points = [NSValue(cgPoint: tw_arc4randomValue(0.25)),NSValue(cgPoint: tw_arc4randomValue(0.25)),NSValue(cgPoint: tw_arc4randomValue(0.25)),NSValue(cgPoint: tw_arc4randomValue(0.25)),NSValue(cgPoint: tw_arc4randomValue(0.25))]
        keyFrameAnimate.values = points
        self.add(keyFrameAnimate, forKey: "opacityAnimation")
        CATransaction.commit()
    }
    func rotationAnimation(){
        CATransaction.begin()
        let keyFrameAnimate = CAKeyframeAnimation(keyPath: "transform")
        keyFrameAnimate.duration = 0.3
        keyFrameAnimate.valueFunction = CAValueFunction(name: .rotateZ)
        keyFrameAnimate.isAdditive = true
        keyFrameAnimate.repeatCount = MAXFLOAT
        keyFrameAnimate.isRemovedOnCompletion = false
        keyFrameAnimate.beginTime = CFTimeInterval(arc4random_uniform(1000 + 1)) * 0.2 * 0.25
        let radius = 0.104
        keyFrameAnimate.values = [(-radius),radius,(-radius)]
        self.add(keyFrameAnimate, forKey: "transformAnimation")
        CATransaction.commit()
    }
    func fadeInOutAnimation(_ beginTime: CFTimeInterval){
        CATransaction.begin()
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        fadeAnimation.fromValue = 0
        fadeAnimation.toValue = 1
        fadeAnimation.autoreverses = true
        fadeAnimation.duration = 0.4
        fadeAnimation.fillMode = .forwards
        fadeAnimation.beginTime = beginTime
        CATransaction.setCompletionBlock {
            self.removeFromSuperlayer()
        }
        self.add(fadeAnimation, forKey: "opacityAnimation")
        CATransaction.commit()
    }
    func tw_arc4randomValue(_ range: CGFloat) -> CGPoint{
        let x: CGFloat = -range + CGFloat(arc4random_uniform(1000)) / 1000.0 * 2.0 * range
        let y: CGFloat = -range + CGFloat(arc4random_uniform(1000)) / 1000.0 * 2.0 * range
        return CGPoint(x: x, y: y)
    }
}
