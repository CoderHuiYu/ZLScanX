//
//  SortViewController.swift
//  WeScan
//
//  Created by Tyoung on 2018/11/29.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

protocol SortViewControllerProtocol: NSObjectProtocol{
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
        view.backgroundColor = UIColor.white

        collectionView.photoModels = photoModels
        view.addSubview(collectionView)
        
        let sortView = SortNavView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kNavHeight))
        view.addSubview(sortView)
        
        sortView.leftBtnComplete  = { () in self.dismiss(animated: true, completion: nil)}
        sortView.rightBtnComplete = { [weak self] () in
            guard let strongSelf = self else {return}
            if strongSelf.delegate != nil {strongSelf.delegate?.sortDidFinished(strongSelf.collectionView.photoModels)}
            strongSelf.dismiss(animated: true, completion: nil)
        }
    }
}
