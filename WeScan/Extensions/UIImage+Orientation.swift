//
//  UIImage+Orientation.swift
//  WeScan
//
//  Created by Boris Emorine on 2/16/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import Foundation

extension UIImage {
    
    /// Returns the same image with a portrait orientation.
    func applyingPortraitOrientation() -> UIImage {
        switch imageOrientation {
        case .up:
            return rotated(by: Measurement(value: Double.pi, unit: .radians), options: []) ?? self
        case .down:
            return rotated(by: Measurement(value: Double.pi, unit: .radians), options: [.flipOnVerticalAxis, .flipOnHorizontalAxis]) ?? self
        case .left:
            return self
        case .right:
            return rotated(by: Measurement(value: Double.pi / 2.0, unit: .radians), options: []) ?? self
        default:
            return self
        }
    }
    
    /// Data structure to easily express rotation options.
    struct RotationOptions: OptionSet {
        let rawValue: Int
        
        static let flipOnVerticalAxis = RotationOptions(rawValue: 1)
        static let flipOnHorizontalAxis = RotationOptions(rawValue: 2)
    }
    
    /// Rotate the image by the given angle, and perform other transformations based on the passed in options.
    ///
    /// - Parameters:
    ///   - rotationAngle: The angle to rotate the image by.
    ///   - options: Options to apply to the image.
    /// - Returns: The new image rotated and optentially flipped (@see options).
    func rotated(by rotationAngle: Measurement<UnitAngle>, options: RotationOptions = []) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        let rotationInRadians = CGFloat(rotationAngle.converted(to: .radians).value)
        let transform = CGAffineTransform(rotationAngle: rotationInRadians)
        let cgImageSize = CGSize(width: cgImage.width, height: cgImage.height)
        var rect = CGRect(origin: .zero, size: cgImageSize).applying(transform)
        rect.origin = .zero
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let renderer = UIGraphicsImageRenderer(size: rect.size, format: format)
        
        let image = renderer.image { renderContext in
            renderContext.cgContext.translateBy(x: rect.midX, y: rect.midY)
            renderContext.cgContext.rotate(by: rotationInRadians)
            
            let x = options.contains(.flipOnVerticalAxis) ? -1.0 : 1.0
            let y = options.contains(.flipOnHorizontalAxis) ? 1.0 : -1.0
            renderContext.cgContext.scaleBy(x: CGFloat(x), y: CGFloat(y))
            
            let drawRect = CGRect(origin: CGPoint(x: -cgImageSize.width / 2.0, y: -cgImageSize.height / 2.0), size: cgImageSize)
            renderContext.cgContext.draw(cgImage, in: drawRect)
        }
        
        return image
    }
    
    /// Rotates the image based on the information collected by the accelerometer
    func withFixedOrientation() -> UIImage {
        var imageAngle: Double = 0.0
        
        var shouldRotate = true
        switch CaptureSession.current.editImageOrientation {
        case .up:
            shouldRotate = false
        case .left:
            imageAngle = Double.pi / 2
        case .right:
            imageAngle = -(Double.pi / 2)
        case .down:
            imageAngle = Double.pi
        default:
            shouldRotate = false
        }
        
        if shouldRotate,
            let finalImage = rotated(by: Measurement(value: imageAngle, unit: .radians)) {
            return finalImage
        } else {
            return self
        }
    }
    
    func filter(name: String, parameters: [String:Any]) -> UIImage? {
        guard let image = self.cgImage else {
            return nil
        }
        
        let input = CIImage(cgImage: image)
        let output = input.applyingFilter(name, parameters: parameters)
        guard let cgimage = CIContext(options: nil).createCGImage(output, from: input.extent) else {
            return nil
        }
        return UIImage(cgImage: cgimage)
    }
    func colorControImage() -> UIImage?{
            let context = CIContext(options: nil)
            
            let cgI =  CIImage(image: self)
                
            let filter = CIFilter(name: "CIColorControls")
//            filter?.setValue(0.5, forKey:"inputSaturation")
//            filter?.setValue(0.5, forKey:"inputBrightness")
            filter?.setValue(2.0, forKey: "inputContrast")
            
            filter?.setValue(cgI, forKey: kCIInputImageKey)
            let outputCGImage = context.createCGImage(filter!.outputImage!, from: filter!.outputImage!.extent)
            
            let newImage = UIImage(cgImage: outputCGImage!)
//            let resultImage = imageByRemoveWhiteBg()
            print(newImage)
        return newImage
    }
   
    func imageByRemoveWhiteBg() -> UIImage? {
        let colorMasking: [CGFloat] = [160, 255, 160, 255, 160, 255]
        return transparentColor(colorMasking: colorMasking)
    }
    
    func transparentColor(colorMasking:[CGFloat]) -> UIImage? {
        if let rawImageRef = self.cgImage {
            UIGraphicsBeginImageContext(self.size)
            if let maskedImageRef = rawImageRef.copy(maskingColorComponents: colorMasking) {
                let context: CGContext = UIGraphicsGetCurrentContext()!
                context.translateBy(x: 0.0, y: self.size.height)
                context.scaleBy(x: 1.0, y: -1.0)
                context.draw(maskedImageRef, in: CGRect(x:0, y:0, width:self.size.width,
                                                        height:self.size.height))
                context.setFillColor(UIColor.white.cgColor)
                let result = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return result
            }
        }
        return nil
    }
    
    func ciConvolutionImage() -> UIImage
    {
        let cgI =  CIImage(image: self)
        let filter = CIFilter(name: "CIConvolution3X3")
        filter?.setValue(cgI, forKey: kCIInputImageKey)
        let weights:[CGFloat] = [0,-1,0,
                                 -1,5,-1,
                                 0,-1,0]
        let inputWeights = CIVector(values: weights, count: 9)
        filter?.setValue(inputWeights, forKey: kCIInputWeightsKey)
        filter?.setValue(0, forKey: kCIInputBiasKey)
        let outImage = filter?.outputImage
        let context = CIContext(options: nil)
        let outputCGImage = context.createCGImage(outImage!, from: outImage!.extent)
        let newImage = UIImage(cgImage: outputCGImage!)
        return newImage
    }
}
