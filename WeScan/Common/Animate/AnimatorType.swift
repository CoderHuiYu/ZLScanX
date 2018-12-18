//
//  AnimatorType.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/13.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

/// AnimationType available to perform/
///
/// - from: Animation with direction and distance.
/// - zoom: Zoom animation.
/// - rotate: Rotation animation.
enum AnimationType: Animation {
    
    case from(direction: Direction, offset: CGFloat)
    case zoom(scale: CGFloat)
    case rotate(angle: CGFloat)
    
    /// Creates the corresponding CGAffineTransform for AnimationType.from.
    var initialTransform: CGAffineTransform {
        switch self {
        case .from(let direction, let offset):
            let sign = direction.sign
            if direction.isVertical { return CGAffineTransform(translationX: 0, y: offset * sign) }
            return CGAffineTransform(translationX: offset * sign, y: 0)
        case .zoom(let scale):
            return CGAffineTransform(scaleX: scale, y: scale)
        case .rotate(let angle):
            return CGAffineTransform(rotationAngle: angle)
        }
    }
    
    /// Generates a random Animation.
    ///
    /// - Returns: Newly generated random Animation.
    static func random() -> Animation {
        let index = Int(arc4random_uniform(3))
        if index == 1 {
            return AnimationType.from(direction: Direction.random(),
                                      offset: ViewAnimatorConfig.offset)
        } else if index == 2 {
            let scale = Double.random(min: 0, max: ViewAnimatorConfig.maxZoomScale)
            return AnimationType.zoom(scale: CGFloat(scale))
        }
        let angle = CGFloat.random(min: -ViewAnimatorConfig.maxRotationAngle,
                                   max: ViewAnimatorConfig.maxRotationAngle)
        return AnimationType.rotate(angle: angle)
    }
}
