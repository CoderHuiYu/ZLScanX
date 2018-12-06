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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    func setupViews(){
        view.backgroundColor = .black
        let leftBtn = UIButton()
        leftBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        leftBtn.setTitle("Back", for: .normal)
        leftBtn.setTitleColor( .black, for: .normal)
        leftBtn.addTarget(self, action: #selector(leftBtnClick), for: .touchUpInside)
        let leftItem = UIBarButtonItem.init(customView: leftBtn)
        navigationItem.leftBarButtonItem = leftItem
    }
    func loadPDF(){
        view.showLoadingView()
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
                for index in 0..<self.imageArray.count {
                    let model = sortDict["\(index)"]
                    model?.save(handle: { (isSuccess) in
                        print(index)
                    })
                }
                self.perform(#selector(self.pushToScanVC), with: nil, afterDelay: TimeInterval(3.0))
            }
        }
        
    }
    @objc func leftBtnClick(){
        dismiss(animated: true, completion: nil)
    }
    @objc func pushToScanVC(){
        self.view.hideLoadingView()
        let vc = ScannerViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


