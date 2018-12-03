//
//  SortViewController.swift
//  WeScan
//
//  Created by Tyoung on 2018/11/29.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

protocol SortViewControllerProtocol:NSObjectProtocol{
    func sortDidFinished(_ photoModels: [ZLPhotoModel])
}

class SortViewController: UIViewController {
    weak var delegate: SortViewControllerProtocol?

    var photoModels = [ZLPhotoModel]()
    
    var collectionView: SortCollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: (kScreenWidth - 50) / 3, height: kScreenWidth/3)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        let collectionView = SortCollectionView(frame: CGRect(x: 0, y: kNavHeight, width: kScreenWidth, height: kScreenHeight), collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 30, left: 10, bottom: 0, right: 10)
        return collectionView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        creatCollectionView()
    }
    func creatCollectionView(){
        title = "Sort"
        self.view.backgroundColor = UIColor.white

        collectionView.photoModels = photoModels
        self.view.addSubview(collectionView)
        
        let toolView = UIView()
        toolView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kNavHeight)
        toolView.backgroundColor = UIColor.white
        view.addSubview(toolView)
        
        let titleLabel = UILabel()
        titleLabel.text = "Sort"
        titleLabel.textColor = UIColor.black
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.frame = CGRect(x: 0, y: kNavHeight - 44, width: kScreenWidth, height: 44)
        titleLabel.textAlignment = .center
        toolView.addSubview(titleLabel)
        
        let leftBtn = UIButton()
        leftBtn.setTitle("cancle", for: .normal)
        leftBtn.setTitleColor(RGBColor(r: 80, g: 165, b: 195), for: .normal)
        leftBtn.frame = CGRect(x: 10, y: kNavHeight-44, width: 54, height: 44)
        leftBtn.addTarget(self, action: #selector(leftBtnClick), for: .touchUpInside)
        toolView.addSubview(leftBtn)
        
        let rightBtn = UIButton()
        rightBtn.setTitle("Done", for: .normal)
        rightBtn.setTitleColor(RGBColor(r: 80, g: 165, b: 195), for: .normal)
        rightBtn.frame = CGRect(x: kScreenWidth-54, y: kNavHeight-44, width: 44, height: 44)
        rightBtn.addTarget(self, action: #selector(rightBtnClick), for: .touchUpInside)
        toolView.addSubview(rightBtn)

        let layer = CAGradientLayer()
        layer.frame = CGRect(x: 0, y: kNavHeight, width: kScreenWidth, height: 20)
        layer.colors = [UIColor.white.cgColor,UIColor.white.withAlphaComponent(0).cgColor]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 0, y: 1)
        layer.locations = [0,1]
        toolView.layer.addSublayer(layer)
    }
    @objc func leftBtnClick(){
        self.dismiss(animated: true, completion: nil)
    }
    @objc func rightBtnClick(){
        if self.delegate != nil {
            self.delegate?.sortDidFinished(collectionView.photoModels)
        }
        self.dismiss(animated: true, completion: nil)
    }
}
