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
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        guard let collectionView = collectionView else {
            return CGPoint.zero
        }
        
        var offsetAdjustment = CGFloat(MAXFLOAT)   //当前处理器能处理的最大浮点数
        let horizontalCenter = proposedContentOffset.x + (self.collectionView!.bounds.width / 2.0)//collectionView落在屏幕中点的x坐标
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0.0, width:  self.collectionView!.bounds.size.width, height: self.collectionView!.bounds.size.height)
        let array = super.layoutAttributesForElements(in: targetRect) //目标区域中包含的cell
        for layoutAttributes in array!{
            let itemHorizontalCenter = layoutAttributes.center.x
            if(abs(itemHorizontalCenter-horizontalCenter) < abs(offsetAdjustment)){   //ABS求绝对值
                offsetAdjustment = itemHorizontalCenter-horizontalCenter     //比较谁离中心点更近
            }
        }
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)  //返回collectionView最终停留的位置
    }
    
    override var collectionViewContentSize: CGSize {
        guard let lastAttr = attributes.last else {
            return CGSize.zero
        }
        return CGSize(width: lastAttr.frame.maxX + sectionInset.right, height: lastAttr.frame.height)
    }
    
}
