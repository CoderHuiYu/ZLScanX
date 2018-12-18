//
//  ZLScanZoomGestureController.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/17.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import Foundation
import AVFoundation

//this is helper ,to help find the closest cornerView .it hadle the logic
final class ZLScanZoomGestureController {
    
    private let image: UIImage
    private let quadView: ZLQuadrilateralView
    
    init(image: UIImage, quadView: ZLQuadrilateralView) {
        self.image = image
        self.quadView = quadView
    }
    
    private var previousPanPosition: CGPoint?
    private var closestCorner: ZLCornerPosition?
    
    @objc func handle(pan: UIGestureRecognizer) {
        guard let drawnQuad = quadView.quad else {
            return
        }
        
        guard pan.state != .ended else {
            self.previousPanPosition = nil
            self.closestCorner = nil
            quadView.resetHighlightedCornerViews()
            return
        }
        
        let position = pan.location(in: quadView)
        
        let previousPanPosition = self.previousPanPosition ?? position
        let closestCorner = self.closestCorner ?? position.closestCornerFrom(quad: drawnQuad)
        
        let offset = CGAffineTransform(translationX: position.x - previousPanPosition.x, y: position.y - previousPanPosition.y)
        let cornerView = quadView.cornerViewForCornerPosition(position: closestCorner)
        let draggedCornerViewCenter = cornerView.center.applying(offset)
        
        quadView.moveCorner(cornerView: cornerView, atPoint: draggedCornerViewCenter)
        
        self.previousPanPosition = position
        self.closestCorner = closestCorner
        
        let scale = image.size.width / quadView.bounds.size.width
        let scaledDraggedCornerViewCenter = CGPoint(x: draggedCornerViewCenter.x * scale, y: draggedCornerViewCenter.y * scale)
        //get the zoomimage,so can show it on the view
        guard let zoomedImage = image.scaledImage(atPoint: scaledDraggedCornerViewCenter, scaleFactor: 2.5, targetSize: quadView.bounds.size) else {
            return
        }
        quadView.highlightCornerAtPosition(position: closestCorner, with: zoomedImage)
    }
}

