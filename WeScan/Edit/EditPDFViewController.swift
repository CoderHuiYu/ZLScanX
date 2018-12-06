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
        
//        let array = imageArray.map { (image) -> UIImage in
//            let dict = ZLPhotoManager.getRectDict(Quadrilateral(topLeft: CGPoint.zero, topRight: CGPoint.zero, bottomRight: CGPoint.zero, bottomLeft: CGPoint.zero))
//            let model = ZLPhotoModel(image, image, image, false, dict)
//            return model
//        }
    }
    @objc func leftBtnClick(){
        dismiss(animated: true, completion: nil)
    }
}


