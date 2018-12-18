//
//  ZLScanCIRectangleDetector.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import Foundation
import AVFoundation

/// Class used to detect rectangles from an image.
struct ZLScanCIRectangleDetector {
    
    static let rectangleDetector = CIDetector(ofType: CIDetectorTypeRectangle, context: CIContext(options: nil), options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
    
    /// Detects rectangles from the given image on iOS 10.
    ///
    /// - Parameters:
    ///   - image: The image to detect rectangles on.
    /// - Returns: The biggest detected rectangle on the image.
    static func rectangle(forImage image: CIImage, completion: @escaping ((ZLQuadrilateral?) -> Void)) {
        
        let biggestRectangle = rectangle(forImage: image)
        completion(biggestRectangle)
    }
    
    static func rectangle(forImage image: CIImage) -> ZLQuadrilateral? {
        
        guard let rectangleFeatures = rectangleDetector?.features(in: image) as? [CIRectangleFeature] else {
            return nil
        }
        
        let quads = rectangleFeatures.map { rectangle in
            return ZLQuadrilateral(rectangleFeature: rectangle)
        }
        
        return quads.biggest()
    }
}
