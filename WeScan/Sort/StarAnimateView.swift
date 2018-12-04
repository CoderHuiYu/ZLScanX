//
//  StarAnimateView.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/4.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

class StarAnimateView: UIView {
    var starLayer = CAEmitterLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.addSublayer(starLayer)
        starLayer.emitterSize = self.frame.size
        starLayer.emitterMode = .points
        starLayer.emitterShape = .point
        starLayer.emitterPosition = CGPoint(x: self.layer.bounds.size.width, y: 0)
        
        let starCell = CAEmitterCell()
        starCell.name = "starCell"
        starCell.birthRate = 20.0
        starCell.lifetime = 5.0
        
        starCell.velocity = 40.0
        starCell.velocityRange = 100.0
        starCell.yAcceleration = 15.0
        
        starCell.emissionLongitude = .pi
        starCell.emissionRange = .pi * 4
        
        starCell.scale = 0.2
        starCell.scaleRange = 0.1
        starCell.scaleSpeed = 0.02
        
        starCell.contents = UIImage(named: "circle_white", in: Bundle.init(for: self.classForCoder), compatibleWith: nil)?.cgImage
        starCell.color = RGBColor(r: 0.5, g: 0, b: 0.5).cgColor
        starCell.redRange = 1.0
        starCell.greenRange = 1.0
        starCell.blueRange = 1.0
        starCell.alphaRange = 0.8
        starCell.alphaSpeed = -0.1
        
        starLayer.emitterCells = [starCell]
        
        let animate = CABasicAnimation(keyPath: "emitterCells.starCell.scale")
        animate.fromValue = 0.2
        animate.toValue = 0.5
        animate.duration = 1.0
        animate.timingFunction = CAMediaTimingFunction.init(name: .linear)
        
        let transition = CATransition()
    
        /*
         CABasicAnimation * anim = [CABasicAnimation animationWithKeyPath:@"emitterCells.colorBallCell.scale"];
         anim.fromValue = @0.2f;
         anim.toValue = @0.5f;
         anim.duration = 1.f;
         anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
         
         // 用事务包装隐式动画
         [CATransaction begin];
         [CATransaction setDisableActions:YES];
         [self.colorBallLayer addAnimation:anim forKey:nil];
         [self.colorBallLayer setValue:[NSValue valueWithCGPoint:position] forKeyPath:@"emitterPosition"];
         [CATransaction commit];
         // 2. 配置CAEmitterCell
         CAEmitterCell * colorBallCell = [CAEmitterCell emitterCell];
         colorBallCell.name = @"colorBallCell";
         
         colorBallCell.birthRate = 20.f;
         colorBallCell.lifetime = 10.f;
         
         colorBallCell.velocity = 40.f;
         colorBallCell.velocityRange = 100.f;
         colorBallCell.yAcceleration = 15.f;
         
         colorBallCell.emissionLongitude = M_PI; // 向左
         colorBallCell.emissionRange = M_PI_4; // 围绕X轴向左90度
         
         colorBallCell.scale = 0.2;
         colorBallCell.scaleRange = 0.1;
         colorBallCell.scaleSpeed = 0.02;
         
         colorBallCell.contents = (id)[[UIImage imageNamed:@"circle_white"] CGImage];
         colorBallCell.color = [[UIColor colorWithRed:0.5 green:0.f blue:0.5 alpha:1.f] CGColor];
         colorBallCell.redRange = 1.f;
         colorBallCell.greenRange = 1.f;
         colorBallCell.blueSpeed = 1.f;
         colorBallCell.alphaRange = 0.8;
         colorBallCell.alphaSpeed = -0.1f;
         
         // 添加
         colorBallLayer.emitterCells = @[colorBallCell];
         */
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
