//
//  ZLPhotoWaterFallView.swift
//  WaterFallCollection
//
//  Created by apple on 2018/11/29.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

private let kCellIdentifier = "ZLPhotoCellIdentifier"

struct ZLPhotoModel {
    var imageData: Data
    var imageSize: CGSize
}

class ZLPhotoWaterFallView: UIView {
    
    // backColor
    var backViewColor: UIColor? {
        didSet {
            guard let color = backViewColor else {
                return
            }
            backgroundColor = color
            collectionView.backgroundColor = color
        }
    }
    
    fileprivate var photoModels = [ZLPhotoModel]()
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = ZLPhotoWaterFallLayout()
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .horizontal
        layout.dataSource = self
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
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
        addSubview(collectionView)
    }
}


extension ZLPhotoWaterFallView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellIdentifier, for: indexPath) as! ZLPhotoCell
        cell.photoModel = photoModels[indexPath.row]
        cell.itemDidRemove = { [weak self] (item) in
            self?.removeItem(item)
        }
        return cell
    }
    
    func removeItem(_ cell: ZLPhotoCell) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        photoModels.remove(at: indexPath.row)
        collectionView.reloadData()
    }
}

extension ZLPhotoWaterFallView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension ZLPhotoWaterFallView: ZLPhotoWaterFallLayoutDataSource {
    func waterFallLayout(_ layout: ZLPhotoWaterFallLayout, indexPath: IndexPath) -> CGFloat {
        let model = photoModels[indexPath.row]
        return getItemWidth(model.imageSize)
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

