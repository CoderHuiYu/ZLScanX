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
    func convertPDF(_ models: [ZLPhotoModel], fileName: String) -> Bool{
        if models.count == 0 {return false}
        let pdfPath = saveDirectory(fileName)
        print(pdfPath)
        
        let res = UIGraphicsBeginPDFContextToFile(pdfPath, .zero, nil)
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
        return res
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
            let maxSize = 300
            let tempSize = max((rect?.size.width)!, (rect?.size.height)!)
            if Int(tempSize) > maxSize{
                if (rect?.size.width)! > (rect?.size.height)! {
                    let tRect = CGRect(x: (rect?.origin.x)!, y: (rect?.origin.y)!, width: CGFloat(maxSize), height: CGFloat(maxSize) * (rect?.size.height)! / (rect?.size.width)!)
                    rect = tRect
                }else {
                    let tRect = CGRect(x: (rect?.origin.x)!, y: (rect?.origin.y)!, width: CGFloat(maxSize) * (rect?.size.width)! / (rect?.size.height)!, height: CGFloat(maxSize))
                    rect = tRect
                }
            }
            if !(rect?.equalTo(.null))!{
                UIGraphicsBeginImageContext((rect?.size)!)
                let drawingTransform = currentPage?.getDrawingTransform(.cropBox, rect: rect!, rotate: 0, preserveAspectRatio: true)
                let ctx = UIGraphicsGetCurrentContext()
                ctx?.ctm.concatenating(drawingTransform!)
                ctx?.drawPDFPage(currentPage!)
                image = UIGraphicsGetImageFromCurrentImageContext()
                image = UIImage.init(cgImage: (image?.cgImage)!, scale: 1.0, orientation: .right)
                UIGraphicsEndImageContext()
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
}
