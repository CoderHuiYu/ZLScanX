//
//  Direction.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/13.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

/// Direction of the animation used in AnimationType.from.
enum Direction: Int {
    
    case top
    case left
    case right
    case bottom
    
    /// Checks if the animation should go on the X or Y axis.
    var isVertical: Bool {
        switch self {
        case .top, .bottom:
            return true
        default:
            return false
        }
    }
    
    /// Positive or negative value to determine the direction.
    var sign: CGFloat {
        switch self {
        case .top, .left:
            return -1
        case .right, .bottom:
            return 1
        }
    }
    
    /// Random direction.
    static func random() -> Direction {
        let rawValue = Int(arc4random_uniform(4))
        return Direction(rawValue: rawValue)!
    }
}
