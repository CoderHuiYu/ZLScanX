//
//  ZLPhotoModel.swift
//  WeScan
//
//  Created by apple on 2018/12/4.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

let kPathDocument = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
let kPhotoModelDataPath = "\(kPathDocument)/WescanData.plist"

struct ZLPhotoModel {
    
    // local store
    var originalImagePath: String
    
    var scannedImagePath: String
    
    var enhancedImagePath: String
    
    var isEnhanced: Bool
    
    var rectangle: [String: [String: Double]]
    
    
    // to show
    var scannedImage: UIImage
    var enhancedImage: UIImage
    var imageSize: CGSize
    
    var isSelected: Bool = false
    
    var detectedRectangle: Quadrilateral = Quadrilateral(topLeft: CGPoint.zero, topRight: CGPoint.zero, bottomRight: CGPoint.zero, bottomLeft: CGPoint.zero)
    
    init(_ originalImagePath: String, _ scannedImagePath: String, _ enhancedImagePath: String, _ isEnhanced: Bool,_ rectangle: [String: [String: Double]]) {
        
        self.originalImagePath = originalImagePath
        self.scannedImagePath = scannedImagePath
        self.enhancedImagePath = enhancedImagePath
        self.isEnhanced = isEnhanced
        self.rectangle = rectangle
        
        self.scannedImage = UIImage(contentsOfFile: kPhotoFileDataPath + "/\(scannedImagePath)") ?? UIImage()
        self.enhancedImage = UIImage(contentsOfFile: kPhotoFileDataPath + "/\(enhancedImagePath)") ?? UIImage()
        
        self.imageSize = enhancedImage.size
        
        guard let topLeftDict = rectangle["topLeft"] else {
            return
        }
        let topLeft = CGPoint(x: topLeftDict["x"] ?? 0.0, y: topLeftDict["y"] ?? 0.0)
        
        guard let topRightDict = rectangle["topRight"] else {
            return
        }
        let topRight = CGPoint(x: topRightDict["x"] ?? 0.0, y: topRightDict["y"] ?? 0.0)
        
        guard let bottomRightDict = rectangle["bottomRight"] else {
            return
        }
        let bottomRight = CGPoint(x: bottomRightDict["x"] ?? 0.0, y: bottomRightDict["y"] ?? 0.0)
        
        guard let bottomLeftDict = rectangle["bottomLeft"] else {
            return
        }
        let bottomLeft = CGPoint(x: bottomLeftDict["x"] ?? 0.0, y: bottomLeftDict["y"] ?? 0.0)
        
        detectedRectangle = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
    }
    
}

extension ZLPhotoModel {
    
    
    func save(handle:((_ isSuccess: Bool)->())) {
        
        let rectDict: [String: Any] = rectangle
        let dict: [String : Any] = ["originalImagePath":originalImagePath,
                                    "scannedImagePath":scannedImagePath,
                                    "enhancedImagePath":enhancedImagePath,
                                    "isEnhanced":isEnhanced,
                                    "rectangle":rectDict]
        
        if let array = NSMutableArray(contentsOfFile: kPhotoModelDataPath) {
            array.add(dict)
            let isSuccess = array.write(toFile: kPhotoModelDataPath, atomically: true)
            handle(isSuccess)
        } else {
            let array = NSMutableArray()
            array.add(dict)
            let isSuccess = array.write(toFile: kPhotoModelDataPath, atomically: true)
            handle(isSuccess)
        }
    }
    
    func remove(handle:((_ isSuccess: Bool)->())) {
        if let array = NSMutableArray(contentsOfFile: kPhotoModelDataPath) {
            var index: Int = 0
            for dict in array {
                guard let dict = dict as? [String: Any] else {
                    handle(false)
                    return
                }
                guard let path = dict["originalImagePath"] as? String else {
                    handle(false)
                    return
                }
                if path == originalImagePath {
                    break
                }
                index += 1
            }
            
            ZLPhotoManager.removeImage(self) { (isSuccess) in
                if isSuccess {
                    array.removeObject(at: index)
                    let isSuccess = array.write(toFile: kPhotoModelDataPath, atomically: true)
                    handle(isSuccess)
                } else {
                    handle(false)
                }
            }
            
        } else {
            handle(false)
        }
    }
    
    func replace(_ originalImage: UIImage, _ scannedImage: UIImage, _ enhancedImage: UIImage, _ isEnhanced: Bool,_ detectedRect: Quadrilateral, handle:@escaping ((_ isSuccess: Bool, _ changedModel: ZLPhotoModel?)->())) {
        if let array = NSMutableArray(contentsOfFile: kPhotoModelDataPath) {
            var index: Int = 0
            for dict in array {
                guard let dict = dict as? [String: Any] else {
                    handle(false, nil)
                    return
                }
                guard let path = dict["originalImagePath"] as? String else {
                    handle(false, nil)
                    return
                }
                if path == originalImagePath {
                    break
                }
                index += 1
            }
            
            
            ZLPhotoManager.saveImage(originalImage, scannedImage, enhancedImage) { (oriPath, scanPath, enhanPath) in
                
                if let oritempPath = oriPath, let scantempPath = scanPath, let enhantempPath = enhanPath  {
                    
                    // remove last model data
                    ZLPhotoManager.removeImage(self) { (isSuccess) in
                        if isSuccess {
                            
                            array.removeObject(at: index)
                            
                            let photoModel = ZLPhotoModel.init(oritempPath, scantempPath, enhantempPath, isEnhanced, ZLPhotoManager.getRectDict(detectedRect))
                            
                            
                            let rectDict: [String: Any] = photoModel.rectangle
                            let dict: [String : Any] = ["originalImagePath":oritempPath,
                                                        "scannedImagePath":scantempPath,
                                                        "enhancedImagePath":enhantempPath,
                                                        "isEnhanced": isEnhanced,
                                                        "rectangle":rectDict]
                            
                            array.insert(dict, at: index)
                            // save current model data
                            let isSuccess = array.write(toFile: kPhotoModelDataPath, atomically: true)
                            handle(isSuccess, photoModel)
                            
                        } else {
                            handle(false, nil)
                        }
                    }
                }
            }
        
        } else {
            handle(false, nil)
        }
    }
    
    static func getAllModel(handle:((_ isSuccess: Bool,_ models: [ZLPhotoModel]?)->())) {
        guard let array = NSArray(contentsOfFile: kPhotoModelDataPath) else {
            handle(false, nil)
            return
        }
        var models = [ZLPhotoModel]()
        for dict in array {
            guard let tempDict = dict as? [String: Any] else {
                handle(false, nil)
                return
            }
            guard let originalImagePath = tempDict["originalImagePath"] as? String else {
                handle(false, nil)
                return
            }
            guard let scannedImagePath = tempDict["scannedImagePath"] as? String else {
                handle(false, nil)
                return
            }
            guard let enhancedImagePath = tempDict["enhancedImagePath"] as? String else {
                handle(false, nil)
                return
            }
            guard let isEnhanced = tempDict["isEnhanced"] as? Bool else {
                handle(false, nil)
                return
            }
            guard let rectangle = tempDict["rectangle"] as? [String: [String: Double]] else {
                handle(false, nil)
                return
            }
            
            let model = ZLPhotoModel(originalImagePath, scannedImagePath, enhancedImagePath, isEnhanced, rectangle)
            models.append(model)
        }
        
        handle(true, models)
    }
    
    static func removeAllModel(handle:((_ isSuccess: Bool)->())) {
        
        let manager = FileManager.default
        if manager.fileExists(atPath: kPhotoModelDataPath) {
            do {
                try manager.removeItem(atPath: kPhotoModelDataPath)
                ZLPhotoManager.removeAllImage { (isSuccess) in
                    handle(isSuccess)
                }
            } catch let error {
                print("remove photodata plist failed \(error.localizedDescription)")
                handle(false)
            }
        } else {
            handle(false)
        }
    }
    
    static func sortAllModel(_ models: [ZLPhotoModel], handle:((_ isSuccess: Bool)->())) {
        
        ZLPhotoManager.removefile(kPhotoModelDataPath) { (isSuccess) in
            if isSuccess {
                
                let array = NSMutableArray()
                for model in models {
                    
                    let rectDict: [String: Any] = model.rectangle
                    let dict: [String : Any] = ["originalImagePath":model.originalImagePath,
                                                "scannedImagePath":model.scannedImagePath,
                                                "enhancedImagePath":model.enhancedImagePath,
                                                "isEnhanced":model.isEnhanced,
                                                "rectangle":rectDict]
                    
                    array.add(dict)
                }
                
                let isSuccess = array.write(toFile: kPhotoModelDataPath, atomically: true)
                handle(isSuccess)
                
            } else {
                handle(false)
            }
        }
    }
    
}
