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
    var photoModels: [ZLPhotoModel] = []
    
    var collectionView: SortCollectionView = {
        let itemWidth = (kScreenWidth-30) / 3
        let itemHeith = itemWidth * 1.3
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: itemWidth, height: itemHeith )
        layout.minimumLineSpacing = 10
        let collectionView = SortCollectionView(frame: CGRect(x: 0, y: kNavHeight, width: kScreenWidth, height: kScreenHeight - kNavHeight), collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
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
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.frame = CGRect(x: 0, y: kNavHeight - 44, width: kScreenWidth, height: 44)
        titleLabel.textAlignment = .center
        toolView.addSubview(titleLabel)
        
        let leftBtn = UIButton()
        leftBtn.setTitle("back", for: .normal)
        leftBtn.setTitleColor(RGBColor(r: 80, g: 165, b: 195), for: .normal)
        leftBtn.frame = CGRect(x: 10, y: kNavHeight-44, width: 44, height: 44)
        leftBtn.addTarget(self, action: #selector(leftBtnClick), for: .touchUpInside)
        toolView.addSubview(leftBtn)
        
        let rightBtn = UIButton()
        rightBtn.setTitle("done", for: .normal)
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
