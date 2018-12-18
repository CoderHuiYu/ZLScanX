//
//  UIImage+Utils.swift
//  WeScan
//
//  Created by Bobo on 5/25/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import Foundation

extension UIImage {
    
    /// Draws a new cropped and scaled (zoomed in) image.
    ///
    /// - Parameters:
    ///   - point: The center of the new image.
    ///   - scaleFactor: Factor by which the image should be zoomed in.
    ///   - size: The size of the rect the image will be displayed in.
    /// - Returns: The scaled and cropped image.
    func scaledImage(atPoint point: CGPoint, scaleFactor: CGFloat, targetSize size: CGSize) -> UIImage? {
        
        guard let cgImage = self.cgImage else {
            return nil
        }
        
        let scaledSize = CGSize(width: size.width / scaleFactor, height: size.height / scaleFactor)
        let midX = point.x - scaledSize.width / 2.0
        let midY = point.y - scaledSize.height / 2.0
        let newRect = CGRect(x: midX, y: midY, width: scaledSize.width, height: scaledSize.height)
        
        guard let croppedImage = cgImage.cropping(to: newRect) else {
            return nil
        }
        
        return UIImage(cgImage: croppedImage)
    }

    func rotateImage(_ orientation: UIImage.Orientation) -> UIImage {
        
        var rotate:Double = 0.0
        var rect = CGRect.zero
        var translateX:Float = 0
        var translateY:Float = 0
        var scaleX:Float = 0
        var scaleY:Float = 0
        switch (orientation) {
        case UIImage.Orientation.left:
            rotate = .pi/2
            rect = CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width)
            translateX = 0
            translateY = Float(-rect.size.width)
            scaleY = Float(rect.size.width/rect.size.height)
            scaleX = Float(rect.size.height/rect.size.width)
            break;
        case UIImage.Orientation.right:
            rotate = 3 * .pi/2
            rect = CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width)
            translateX = Float(-rect.size.height)
            translateY = 0
            scaleY = Float(rect.size.width/rect.size.height)
            scaleX = Float(rect.size.height/rect.size.width)
            break;
        case UIImage.Orientation.down:
            rotate = .pi
            rect = CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width)
            translateX = Float(-rect.size.width)
            translateY = Float(-rect.size.height)
            break;
        default:
            rotate = 0.0
            rect = CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width)
            translateX = 0
            translateY = 0
            break;
        }
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0.0, y: rect.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.rotate(by: CGFloat(rotate))
        context.translateBy(x: CGFloat(translateX), y: CGFloat(translateY))
        
        context.scaleBy(x:CGFloat(scaleX), y:CGFloat(scaleY))
        context.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        return newImage!
    }
    
    func roundedImage(radius: CGFloat, size: CGSize) -> UIImage {
        var resultImage = UIImage()
        UIGraphicsBeginImageContextWithOptions(size, false, 2.0)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIBezierPath(roundedRect: rect, cornerRadius: size.width/2).addClip()
        draw(in: rect)
        resultImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resultImage
    }
}
