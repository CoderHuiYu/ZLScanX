//
//  EditPDFViewController.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/6.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

class EditPDFViewController: UIViewController ,Convertable{

    var imageArray: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "EditPDF"
        
        setupViews()
        loadPDF()
    }
    func setupViews(){
        view.backgroundColor = .white
        let leftBtn = UIButton()
        leftBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        leftBtn.setTitle("Back", for: .normal)
        leftBtn.setTitleColor( .black, for: .normal)
        leftBtn.addTarget(self, action: #selector(leftBtnClick), for: .touchUpInside)
        let leftItem = UIBarButtonItem.init(customView: leftBtn)
        navigationItem.leftBarButtonItem = leftItem
    }
    func loadPDF(){
        let path = Bundle.main.path(forResource: "testA", ofType: "pdf")
        let url = URL.init(fileURLWithPath: path!)
        imageArray = pdfConvertToImage(url)
        
        var array = [ZLPhotoModel]()
        
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "SavePDFImageQueue")
        
        for image in imageArray {
            queue.async(group: group) {
                group.enter()
                let dict = ZLPhotoManager.getRectDict(Quadrilateral(topLeft: CGPoint.zero, topRight: CGPoint.zero, bottomRight: CGPoint.zero, bottomLeft: CGPoint.zero))
                ZLPhotoManager.saveImage(image, image, image, handle: { (oriPath, scanPath, enhanPath) in
                    if let tempOriPath = oriPath, let tempScanPath = scanPath, let tempEnhanPath = scanPath {
                        let model = ZLPhotoModel(tempOriPath, tempScanPath, tempEnhanPath, false, dict)
                        model.save(handle: { (isSuccess) in
                            array.append(model)
                            group.leave()
                        })   
                    }
                })
            }
        }
        
        group.notify(queue: queue) {
            DispatchQueue.main.async {
                let vc = ScannerViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    @objc func leftBtnClick(){
        dismiss(animated: true, completion: nil)
    }
}


