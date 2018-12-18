//
//  Animation.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/13.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

/// Animation protocol defines the initial transform for a view for it to
/// animate to its identity position.
public protocol Animation {
    
    /// Defines the starting point for the animations.
    var initialTransform: CGAffineTransform { get }
}
