//
//  ZLPhotoWaterFallView.swift
//  WaterFallCollection
//
//  Created by apple on 2018/11/29.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

struct ZLPhotoModel {
    var image: UIImage
    var results: ImageScannerResults
    var imageSize: CGSize
}

private let kCellIdentifier = "ZLPhotoCellIdentifier"
private let kToolBarViewHeight: CGFloat = 44

class ZLPhotoWaterFallView: UIView {
    
    // remove all photo call back
    var deleteActionCallBack: (()->())?
    // selected item call back(completion: selected all and index is 0)
    var selectedItemCallBack: ((_ photoModels: [ZLPhotoModel], _ index: Int)->())?
    
    // backColor
    var backViewColor: UIColor? {
        didSet {
            guard let color = backViewColor else {
                return
            }
//            backgroundColor = color
            collectionView.backgroundColor = color
        }
    }
    
    fileprivate var photoModels = [ZLPhotoModel]()
    
    fileprivate lazy var toolBarView: UIView = {
        let toolBarView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: kToolBarViewHeight))
        toolBarView.backgroundColor = UIColor.clear
        return toolBarView
    }()
    
    fileprivate lazy var deleteButton: UIButton = {
        let deleteButton = UIButton(frame: CGRect(x: completeButton.frame.origin.x - 10 - kToolBarViewHeight, y: 0, width: kToolBarViewHeight, height: kToolBarViewHeight))
        deleteButton.setImage(UIImage(named: "Delete", in: Bundle.init(for: self.classForCoder), compatibleWith: nil), for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteButtonAction), for: .touchUpInside)
        return deleteButton
    }()
    
    fileprivate lazy var completeButton: UIButton = {
        let completeButton = UIButton(frame: CGRect(x: bounds.width - 10 - kToolBarViewHeight, y: 0, width: kToolBarViewHeight, height: kToolBarViewHeight))
        completeButton.setImage(UIImage(named: "Check", in: Bundle.init(for: self.classForCoder), compatibleWith: nil), for: .normal)
        completeButton.addTarget(self, action: #selector(completeButtonAction), for: .touchUpInside)
        return completeButton
    }()
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = ZLPhotoWaterFallLayout()
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .horizontal
        layout.dataSource = self
        let height: CGFloat = bounds.height - kToolBarViewHeight - 10
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: toolBarView.frame.maxY + 10, width: bounds.width, height: height), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.clipsToBounds = false
        collectionView.register(UINib(nibName: "ZLPhotoCell", bundle: Bundle(for: type(of: self))), forCellWithReuseIdentifier: kCellIdentifier)
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

// MARK: - UI
extension ZLPhotoWaterFallView {
    fileprivate func setupUI() {
        addSubview(toolBarView)
        toolBarView.addSubview(deleteButton)
        toolBarView.addSubview(completeButton)
        addSubview(collectionView)
    }
}

// MARK: - DataSouce And Delegate
extension ZLPhotoWaterFallView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellIdentifier, for: indexPath) as! ZLPhotoCell
        cell.cellType = .normal
        cell.photoModel = photoModels[indexPath.row]
        cell.itemDidRemove = { [weak self] (item) in
            self?.removeItem(item)
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let callBack = selectedItemCallBack {
            callBack(photoModels, indexPath.row)
        }
    }
    
    fileprivate func removeItem(_ cell: ZLPhotoCell) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        photoModels.remove(at: indexPath.row)
        collectionView.reloadData()
    }
}


// MARK: - Layout
extension ZLPhotoWaterFallView: ZLPhotoWaterFallLayoutDataSource {
    func waterFallLayout(_ layout: ZLPhotoWaterFallLayout, indexPath: IndexPath) -> CGSize {
        let model = photoModels[indexPath.row]
        return CGSize(width: getItemWidth(model.imageSize), height: collectionView.bounds.height)
    }
    
    fileprivate func getItemWidth(_ imageSize: CGSize) -> CGFloat {
        return imageSize.width * collectionView.bounds.height / imageSize.height
    }
}

// MARK: - 数据操作
extension ZLPhotoWaterFallView {
    func addPhotoModel(_ model: ZLPhotoModel) {
        photoModels.append(model)
        collectionView.reloadData()
    }
}


// MARK: - Event
extension ZLPhotoWaterFallView {
    
    // delete All
    @objc fileprivate func deleteButtonAction() {
        photoModels.removeAll()
        collectionView.reloadData()
    }
    
    // ccompletion
    @objc fileprivate func completeButtonAction() {
        if let callBack = selectedItemCallBack {
            callBack(photoModels, 0)
        }
    }
}
