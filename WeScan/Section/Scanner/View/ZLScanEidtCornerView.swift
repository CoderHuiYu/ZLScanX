//
//  ZLScanEidtCornerView.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

/// A UIView used by corners of a quadrilateral that is aware of its position.
final class ZLScanEditCornerView: UIView {
    
    let position: ZLCornerPosition
    
    /// The image to display when the corner view is highlighted.
    private var image: UIImage?
    
    private(set) var isHighlighted = false
    
    lazy private var circleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 1.0
        return layer
    }()
    
    lazy var dotImageView :UIImageView = {
        let imgView = UIImageView.init(frame: self.frame)
        imgView.image = UIImage.init(named: "crop-handle_20x20_")
        return imgView
    }()
    
    init(frame: CGRect, position: ZLCornerPosition) {
        self.position = position
        super.init(frame: frame)
        addSubview(dotImageView)
        backgroundColor = UIColor.clear
        clipsToBounds = true
        layer.addSublayer(circleLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2.0
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        //Draw a curve based on the inscribed circle of the rectangle ·
        let bezierPath = UIBezierPath(ovalIn: rect.insetBy(dx: circleLayer.lineWidth, dy: circleLayer.lineWidth))
        circleLayer.frame = rect
        circleLayer.path = bezierPath.cgPath
        
        print("rect \(rect),self\(self)")
        image?.draw(in: rect)
    }
    
    func highlightWithImage(_ image: UIImage) {
        isHighlighted = true
        self.image = image
        print("highlight")
        self.setNeedsDisplay()
    }
    
    func reset() {
        isHighlighted = false
        image = nil
        setNeedsDisplay()
    }
    
}
