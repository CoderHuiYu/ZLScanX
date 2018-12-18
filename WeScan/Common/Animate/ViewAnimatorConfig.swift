//
//  ViewAnimatorConfig.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/13.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import Foundation

/// Configuration class for the default values used in animations.
/// All it's values are used when creating 'random' animations as well.
class ViewAnimatorConfig {
    
    /// Amount of movement in points.
    /// Depends on the Direction given to the AnimationType.
    static var offset: CGFloat = 30.0
    
    /// Duration of the animation.
    static var duration: Double = 0.3
    
    /// Interval for animations handling multiple views that need
    /// to be animated one after the other and not at the same time.
    static var interval: Double = 0.075
    
    /// Maximum zoom to be applied in animations using random AnimationType.zoom.
    static var maxZoomScale: Double = 2.0
    
    /// Maximum rotation (left or right) to be applied in animations using random AnimationType.rotate
    static var maxRotationAngle: CGFloat = CGFloat.pi/4
}
