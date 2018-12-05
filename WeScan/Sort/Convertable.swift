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
}
