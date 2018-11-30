//
//  ZLPhotoWaterFallLayout.swift
//  WaterFallCollection
//
//  Created by apple on 2018/11/29.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

@objc protocol ZLPhotoWaterFallLayoutDataSource {
    func waterFallLayout(_ layout: ZLPhotoWaterFallLayout, indexPath: IndexPath) -> CGFloat
}
class ZLPhotoWaterFallLayout: UICollectionViewFlowLayout {

    weak var dataSource: ZLPhotoWaterFallLayoutDataSource?

    fileprivate lazy var attributes = [UICollectionViewLayoutAttributes]()
    
}


extension ZLPhotoWaterFallLayout {
    
    // init
    override func prepare() {
        super.prepare()
        // clear attributes(avoid crash)
        attributes.removeAll()
        guard let collectionView = collectionView else {
            return
        }
        
        let itemCount = collectionView.numberOfItems(inSection: 0)
        let itemHeight = collectionView.bounds.height
        
        var lastItemMaxX: CGFloat = 0
        
        for i in 0..<itemCount {
        
            let indexPath = IndexPath(item: i, section: 0)
            
            let attrs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            guard let itemWidth = dataSource?.waterFallLayout(self, indexPath: indexPath) else {
                fatalError("please setting dataSource")
            }
            
            attrs.frame = CGRect(x: sectionInset.left + lastItemMaxX + minimumLineSpacing, y: 0, width: itemWidth, height: itemHeight)
            attributes.append(attrs)
            lastItemMaxX = attrs.frame.maxX
        }
        
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributes
    }
    
    override var collectionViewContentSize: CGSize {
        guard let lastAttr = attributes.last else {
            return CGSize.zero
        }
        return CGSize(width: lastAttr.frame.maxX, height: lastAttr.frame.height)
    }
    
}
