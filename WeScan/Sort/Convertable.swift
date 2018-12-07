//
//  Convertable.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/5.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import Foundation

protocol Convertable {
    
}
extension Convertable {
    //MARK: -- UIImage Convert To PDF
    func convertPDF(_ models: [ZLPhotoModel], fileName: String) -> String?{
        if models.count == 0 {return nil}
        let pdfPath = saveDirectory(fileName)
        print(pdfPath)
        
        let res = UIGraphicsBeginPDFContextToFile(pdfPath, .zero, nil)
        print(res)
        let pdfbounds = UIGraphicsGetPDFContextBounds()
        let pdfW = pdfbounds.size.width
        let pdfH = pdfbounds.size.height
        
        for (_, model) in models.enumerated() {
            UIGraphicsBeginPDFPage()
            let imageW = model.enhancedImage.size.width
            let imageH = model.enhancedImage.size.height
            if imageW <= pdfW && imageH <= pdfH{
                let originX = (pdfW - imageW) * 0.5
                let originY = (pdfH - imageH) * 0.5
                model.enhancedImage.draw(in: CGRect(x: originX, y: originY, width: imageW, height: imageH))
            }else{
                var w: CGFloat = 0.0
                var h: CGFloat = 0.0
                if imageW / imageH > pdfW / pdfH {
                    w = pdfW - 20
                    h = w * imageH / imageW
                }else{
                    h = pdfH - 20
                    w = h * imageW / imageH
                }
                model.enhancedImage.draw(in: CGRect(x: (pdfW - w) * 0.5, y: (pdfH - h) * 0.5, width: w, height: h))
            }
        }
        UIGraphicsEndPDFContext()
        return pdfPath
    }
    private func saveDirectory(_ fileName: String) -> String{
        creatPDFFolder()
        return pdfSaveFolder() + fileName
    }
    private func creatPDFFolder(){
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: pdfSaveFolder()){
            do{
                try fileManager.createDirectory(atPath: pdfSaveFolder(), withIntermediateDirectories: true, attributes: nil)
            }catch _{
                
            }
        }
    }
    private func pdfSaveFolder() -> String{
        let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last! + "ZLPDF"
        return path
    }
    //MARK: -- PDF Convert To UIImage
    public func pdfConvertToImage(_ fileUrl: URL) -> [UIImage]{
        var images:[UIImage] = []
        let cfUrl: CFURL = fileUrl as CFURL
        var pdf = CGPDFDocument.init(cfUrl)
        let pageSize = pdf?.numberOfPages
        for i in 1 ... pageSize!{
            var image: UIImage?
            let currentPage = pdf?.page(at: i)
            var rect = currentPage?.getBoxRect(.cropBox)
            let rotationAngle = currentPage?.rotationAngle
            if rotationAngle == 90 || rotationAngle == 270{
                let newRect = CGRect(x: (rect?.origin.x)!, y: (rect?.origin.y)!, width: (rect?.size.height)!, height: (rect?.size.width)!)
                rect = newRect
            }
            let maxSize: CGFloat = 700.0
            let tempSize = max((rect?.size.width)!, (rect?.size.height)!)
            if tempSize > maxSize{
                if (rect?.size.width)! > (rect?.size.height)! {
                    let tRect = CGRect(x: (rect?.origin.x)!, y: (rect?.origin.y)!, width: CGFloat(maxSize), height: CGFloat(maxSize) * (rect?.size.height)! / (rect?.size.width)!)
                    rect = tRect
                }else {
//                    let tRect = CGRect(x: (rect?.origin.x)!, y: (rect?.origin.y)!, width: CGFloat(maxSize) * (rect?.size.width)! / (rect?.size.height)!, height: CGFloat(maxSize))
//                    rect = tRect
                }
            }
            if !(rect?.equalTo(.null))!{
                UIGraphicsBeginImageContext((rect?.size)!)
                let drawingTransform = currentPage?.getDrawingTransform(.cropBox, rect: CGRect(x: 0, y: 0, width: (rect?.size.width)!, height:(rect?.size.height)!), rotate: 180, preserveAspectRatio: true)

                let ctx = UIGraphicsGetCurrentContext()
                ctx?.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                ctx?.fill(rect!)
                ctx?.saveGState()
//                ctx?.ctm.translatedBy(x: (0 - (rect?.size.width)!), y: 0 - (rect?.size.height)!)
//                ctx?.ctm.scaledBy(x: 1.0, y: -1.0)
                ctx?.concatenate(drawingTransform!)
//                ctx?.ctm.rotated(by: .pi)
//                ctx?.ctm.translatedBy(x: -((rect?.size.width)!), y: -(rect?.size.height)!)
                ctx?.drawPDFPage(currentPage!)
                ctx?.restoreGState()
                image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                let rect = CGRect(x: 0, y: 0, width: (image?.size.width)!, height: (image?.size.height)!)
                UIGraphicsBeginImageContextWithOptions(rect.size, false, 2)
                let currentContext =  UIGraphicsGetCurrentContext();//获取当前quartz 2d绘图环境
                currentContext?.clip(to: rect)
                currentContext?.rotate(by: .pi)
                currentContext?.translateBy(x: -(rect.size.width), y: -(rect.size.height))
                currentContext?.draw((image?.cgImage)!, in: rect)
                
                let drwaImage = UIGraphicsGetImageFromCurrentImageContext()
                image = drwaImage
            }
            if image != nil{
                // write to file
//                let fileJpgPath = fileUrl.absoluteString.replacingOccurrences(of: ".pdf", with: "\(i).jpg")
//                let data = image?.jpegData(compressionQuality: 0.9)
//                if (data?.count)! > 0 {
//                    let jpgUrl = URL.init(fileURLWithPath: fileJpgPath)
//                    do {
//                        try data?.write(to: jpgUrl)
//                    }catch let err{
//                        print(err)
//                    }
//                }
            }
            images.append(image!)
        }
        pdf = nil
        return images
    }
    //convertPDF to image and store to model
    func loadPDF(_ handle:@escaping ((_ models: [ZLPhotoModel])->())){
        var imageArray = [UIImage]()
        var modelArray = [ZLPhotoModel]()
        let path = Bundle.main.path(forResource: "testA", ofType: "pdf")
        let url = URL.init(fileURLWithPath: path!)
        imageArray = pdfConvertToImage(url)
        
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "SavePDFImageQueue")
        
        var sortDict = [String:ZLPhotoModel]()
        
        for (index,image) in imageArray.enumerated() {
            queue.async(group: group) {
                group.enter()
                let dict = ZLPhotoManager.getRectDict(Quadrilateral(topLeft: CGPoint.zero, topRight: CGPoint.zero, bottomRight: CGPoint.zero, bottomLeft: CGPoint.zero))
                ZLPhotoManager.saveImage(image, image, image, handle: { (oriPath, scanPath, enhanPath) in
                    if let tempOriPath = oriPath, let tempScanPath = scanPath, let tempEnhanPath = enhanPath {
                        let model = ZLPhotoModel(tempOriPath, tempScanPath, tempEnhanPath, false, dict)
                        sortDict["\(index)"] = model
                        group.leave()
                    }
                })
            }
        }
        group.notify(queue: queue) {
            DispatchQueue.main.async {
                for index in 0..<imageArray.count {
                    let model = sortDict["\(index)"]
                    model?.save(handle: { (isSuccess) in
                        print(index)
                        modelArray.append(model!)
                    })
                }
                handle(modelArray)
            }
        }
    }
    
}
