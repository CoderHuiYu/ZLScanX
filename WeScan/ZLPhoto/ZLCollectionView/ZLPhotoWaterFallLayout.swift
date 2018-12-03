//
//  ZLPhotoWaterFallLayout.swift
//  WaterFallCollection
//
//  Created by apple on 2018/11/29.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

@objc protocol ZLPhotoWaterFallLayoutDataSource {
    func waterFallLayout(_ layout: ZLPhotoWaterFallLayout, indexPath: IndexPath) -> CGSize
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
        
        var lastItemMaxX: CGFloat = 0
        
        for i in 0..<itemCount {
        
            let indexPath = IndexPath(item: i, section: 0)
            
            let attrs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            guard let itemSize = dataSource?.waterFallLayout(self, indexPath: indexPath) else {
                fatalError("please setting dataSource")
            }
            
            let minimumSpace = i == 0 ? 0 : minimumLineSpacing
            let sectionLeft = i == 0 ? sectionInset.left : 0
            
            let attrsW: CGFloat = itemSize.width
            let attrsH: CGFloat = itemSize.height
            let attrsX: CGFloat = sectionLeft + lastItemMaxX + minimumSpace
            let attrsY: CGFloat = (collectionView.bounds.size.height - itemSize.height) * 0.5
    
            attrs.frame = CGRect(x: attrsX, y: attrsY, width: attrsW, height: attrsH)
            attributes.append(attrs)
            lastItemMaxX = attrs.frame.maxX
        }
        
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributes
    }
    
    /*
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {

        guard let collectionView = collectionView else {
            return CGPoint.zero
        }
        
        var lastRect: CGRect = CGRect.zero
        lastRect.origin = proposedContentOffset
        lastRect.size = collectionView.frame.size
        
        let array = layoutAttributesForElements(in: lastRect)
        
        let startX = proposedContentOffset.x
        
        let
        //获取可视区域
        let targetRect = CGRect(x: visibleX, y: visibleY, width: visibleW, height: visibleH)
        
        //中心点的值
        let centerX = proposedContentOffset.x + (collectionView.bounds.size.width)/2
        
        //获取可视区域内的attributes对象
        guard let attrArr = super.layoutAttributesForElements(in: targetRect), attrArr.count > 0 else {
            return CGPoint.zero
        }
        
        //如果第0个属性距离最小
        var min_attr = attrArr[0]
        for attributes in attrArr {
            if (abs(attributes.center.x-centerX) < abs(min_attr.center.x-centerX)) {
                min_attr = attributes
            }
        }
        //计算出距离中心点 最小的那个cell 和整体中心点的偏移
        let ofsetX = min_attr.center.x - centerX
        return CGPoint(x: proposedContentOffset.x+ofsetX, y: proposedContentOffset.y)

    }
    */
    
    //
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    
    override var collectionViewContentSize: CGSize {
        guard let lastAttr = attributes.last else {
            return CGSize.zero
        }
        return CGSize(width: lastAttr.frame.maxX + sectionInset.right, height: lastAttr.frame.height)
    }
    
}
