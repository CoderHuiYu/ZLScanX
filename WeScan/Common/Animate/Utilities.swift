//
//  Utilities.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/13.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

// MARK: - Bool
extension Bool {
    
    /// Generates a random bool.
    ///
    /// - Returns: Bool.
    static func random() -> Bool {
        return arc4random_uniform(2) == 0
    }
}

// MARK: Double
extension Double {
    
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    static var random: Double {
        return Double(arc4random()) / 0xFFFFFFFF
    }
    
    /// Generates a random double.
    ///
    /// - Parameters:
    ///   - min: Minimum value of the random value.
    ///   - max: Maximum value of the random value.
    /// - Returns: Generated value.
    static func random(min: Double, max: Double) -> Double {
        return Double.random * (max - min) + min
    }
}

// MARK: Float Extension

extension Float {
    
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    static var random: Float {
        return Float(arc4random()) / 0xFFFFFFFF
    }
}

extension CGFloat {
    
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    static var random: CGFloat {
        return CGFloat(Float.random)
    }
    
    /// Generates a random CGFloat.
    ///
    /// - Parameters:
    ///   - min: Minimum value of the random value.
    ///   - max: Maximum value of the random value.
    /// - Returns: Generated value.
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random * (max - min) + min
    }
}
