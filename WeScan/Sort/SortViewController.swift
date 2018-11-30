//
//  SortViewController.swift
//  WeScan
//
//  Created by Tyoung on 2018/11/29.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

class SortViewController: UIViewController {
    var layout: UICollectionViewFlowLayout?
    override func viewDidLoad() {
        super.viewDidLoad()
        creatCollectionView()
    }
    func creatCollectionView(){
        self.view.backgroundColor = UIColor.white
        self.layout = UICollectionViewFlowLayout.init()
        self.layout!.itemSize = CGSize(width: (kScreenWidth - 50) / 3, height: kScreenWidth/3)
        let collectionView = SortCollectionView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight), collectionViewLayout: self.layout!)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        self.view.addSubview(collectionView)
    }
}

