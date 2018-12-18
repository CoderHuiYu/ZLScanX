//
//  ZLScanningPromptView.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/17.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit
import AVFoundation

/// Simple enum to keep track of the position of the corners of a quadrilateral.
enum ZLCornerPosition {
    case topLeft
    case topRight
    case bottomRight
    case bottomLeft
}

/// The `QuadrilateralView` is a simple `UIView` subclass that can draw a quadrilateral, and optionally edit it.
final class ZLQuadrilateralView: UIView {
    
    let quadLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 1.0
        layer.opacity = 1.0
        layer.isHidden = true
        
        return layer
    }()
    
    /// We want the corner views to be displayed under the outline of the quadrilateral.
    /// Because of that, we need the quadrilateral to be drawn on a UIView above them.
    private let quadView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// The quadrilateral drawn on the view.
    private(set) var quad: ZLQuadrilateral?
    
    public var editable = false {
        didSet {
            print("editavle \(editable)")
            cornerViews(hidden: !editable)
            quadLayer.fillColor = editable ? UIColor(white: 0.0, alpha: 0.6).cgColor : UIColor(white: 1.0, alpha: 0.5).cgColor
            guard let quad = quad else {
                return
            }
            drawQuad(quad, animated: false)
            layoutCornerViews(forQuad: quad)
        }
    }
    
    private var isHighlighted = false {
        didSet (oldValue) {
            guard oldValue != isHighlighted else {
                return
            }
            quadLayer.fillColor = isHighlighted ? UIColor.clear.cgColor : UIColor(white: 0.0, alpha: 0.6).cgColor
            isHighlighted ? bringSubviewToFront(quadView) : sendSubviewToBack(quadView)
        }
    }
    
    lazy var capturingRoudedProgressView: ZLScanRoundedProgressView = {
        let roudedProgressProperty = ZLScanProgressProperty(width: 5, progressEnd: 0, progressColor: UIColor.init(red: 100, green: 100, blue: 100, alpha: 0.7))
        let capturingRoudedProgressView = ZLScanRoundedProgressView(propressProperty: roudedProgressProperty, frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        capturingRoudedProgressView.center = quadView.center
        return capturingRoudedProgressView
    }()
    
    lazy private var showCornerView: ZLScanEditCornerView = {
        return ZLScanEditCornerView(frame: CGRect(origin: CGPoint.init(x: (UIScreen.main.bounds.size.width - 100)/2, y: 10), size: CGSize.init(width: 100, height: 100)), position: .topLeft)
    }()
    
    lazy private var topLeftCornerView: ZLScanEditCornerView = {
        return ZLScanEditCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .topLeft)
    }()
    
    lazy private var topRightCornerView: ZLScanEditCornerView = {
        return ZLScanEditCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .topRight)
    }()
    
    lazy private var bottomRightCornerView: ZLScanEditCornerView = {
        return ZLScanEditCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .bottomRight)
    }()
    
    lazy private var bottomLeftCornerView: ZLScanEditCornerView = {
        return ZLScanEditCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .bottomLeft)
    }()
    
    private let highlightedCornerViewSize = CGSize(width: 2.0, height: 2.0)
    private let cornerViewSize = CGSize(width: 20.0, height: 20.0)
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        addSubview(quadView)
        setupCornerViews()
        setupConstraints()
        quadView.layer.addSublayer(quadLayer)
    }
    
    private func setupConstraints() {
        let quadViewConstraints = [
            quadView.topAnchor.constraint(equalTo: topAnchor),
            quadView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomAnchor.constraint(equalTo: quadView.bottomAnchor),
            trailingAnchor.constraint(equalTo: quadView.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(quadViewConstraints)
    }
    
    private func setupCornerViews() {
        addSubview(showCornerView)
        addSubview(topLeftCornerView)
        addSubview(topRightCornerView)
        addSubview(bottomRightCornerView)
        addSubview(bottomLeftCornerView)
        quadLayer.addSublayer(capturingRoudedProgressView.layer)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        guard quadLayer.frame != bounds else {
            return
        }
        
        quadLayer.frame = bounds
        if let quad = quad {
            drawQuadrilateral(quad: quad, animated: false)
        }
    }
    
    // MARK: - Drawings
    
    /// Draws the passed in quadrilateral.
    ///
    /// - Parameters:
    ///   - quad: The quadrilateral to draw on the view. It should be in the coordinates of the current `QuadrilateralView` instance.
    func drawQuadrilateral(quad: ZLQuadrilateral, animated: Bool) {
        self.quad = quad
        drawQuad(quad, animated: animated)
        if editable {
            cornerViews(hidden: false)
            layoutCornerViews(forQuad: quad)
        }
    }
    
    private func drawQuad(_ quad: ZLQuadrilateral, animated: Bool) {
        var path = quad.path
        
        if editable {
            path = path.reversing()
            let rectPath = UIBezierPath(rect: bounds)
            path.append(rectPath)
        }
        
        if animated == true {
            let pathAnimation = CABasicAnimation(keyPath: "path")
            pathAnimation.duration = 0.2
            quadLayer.add(pathAnimation, forKey: "path")
        }
        
        quadLayer.path = path.cgPath
        quadLayer.isHidden = false
        
        let quadRect = CGRect(x: quadLayer.path?.boundingBox.origin.x ?? 0.0, y: quadLayer.path?.boundingBox.origin.y ?? 0.0, width: quadLayer.path?.boundingBox.size.width ?? 0.0, height: quadLayer.path?.boundingBox.size.height ?? 0.0)
        let quadCenter = CGPoint(x: quadRect.width/2.0 + quadRect.minX, y: quadRect.height/2.0 + quadRect.minY)
        capturingRoudedProgressView.center = quadCenter
    }
    
    private func layoutCornerViews(forQuad quad: ZLQuadrilateral) {
        topLeftCornerView.center = quad.topLeft
        topRightCornerView.center = quad.topRight
        bottomLeftCornerView.center = quad.bottomLeft
        bottomRightCornerView.center = quad.bottomRight
    }
    
    func removeQuadrilateral() {
        quadLayer.path = nil
        quadLayer.isHidden = true
    }
    
    // MARK: - Actions
    
    func moveCorner(cornerView: ZLScanEditCornerView, atPoint point: CGPoint) {
        guard let quad = quad else {
            return
        }
        
        let validPoint = self.validPoint(point, forCornerViewOfSize: cornerView.bounds.size, inView: self)
        
        cornerView.center = validPoint
        let updatedQuad = update(quad, withPosition: validPoint, forCorner: cornerView.position)
        
        self.quad = updatedQuad
        drawQuad(updatedQuad, animated: false)
    }
    
    func highlightCornerAtPosition(position: ZLCornerPosition, with image: UIImage) {
        guard editable else {
            return
        }
        isHighlighted = true
        
        let cornerView = cornerViewForCornerPosition(position: position)
        guard cornerView.isHighlighted == false else {
            cornerView.highlightWithImage(image)
            showCornerView.highlightWithImage(image)
            return
        }
        
        let origin = CGPoint(x: cornerView.frame.origin.x - (highlightedCornerViewSize.width - cornerViewSize.width) / 2.0,
                             y: cornerView.frame.origin.y - (highlightedCornerViewSize.height - cornerViewSize.height) / 2.0)
        cornerView.frame = CGRect(origin: origin, size: highlightedCornerViewSize)
        //        print(image)
        showCornerView.isHidden = false
        showCornerView.highlightWithImage(image)
        cornerView.highlightWithImage(image)
    }
    
    func resetHighlightedCornerViews() {
        isHighlighted = false
        showCornerView.isHidden = true
        resetHighlightedCornerViews(cornerViews: [topLeftCornerView, topRightCornerView, bottomLeftCornerView, bottomRightCornerView])
    }
    
    private func resetHighlightedCornerViews(cornerViews: [ZLScanEditCornerView]) {
        cornerViews.forEach { (cornerView) in
            resetHightlightedCornerView(cornerView: cornerView)
        }
    }
    
    private func resetHightlightedCornerView(cornerView: ZLScanEditCornerView) {
        cornerView.reset()
        let origin = CGPoint(x: cornerView.frame.origin.x + (cornerView.frame.size.width - cornerViewSize.width) / 2.0,
                             y: cornerView.frame.origin.y + (cornerView.frame.size.height - cornerViewSize.width) / 2.0)
        cornerView.frame = CGRect(origin: origin, size: cornerViewSize)
        cornerView.setNeedsDisplay()
    }
    
    // MARK: Validation
    
    /// Ensures that the given point is valid - meaning that it is within the bounds of the passed in `UIView`.
    ///
    /// - Parameters:
    ///   - point: The point that needs to be validated.
    ///   - cornerViewSize: The size of the corner view representing the given point.
    ///   - view: The view which should include the point.
    /// - Returns: A new point which is within the passed in view.
    private func validPoint(_ point: CGPoint, forCornerViewOfSize cornerViewSize: CGSize, inView view: UIView) -> CGPoint {
        var validPoint = point
        
        if point.x > view.bounds.width {
            validPoint.x = view.bounds.width
        } else if point.x < 0.0 {
            validPoint.x = 0.0
        }
        
        if point.y > view.bounds.height {
            validPoint.y = view.bounds.height
        } else if point.y < 0.0 {
            validPoint.y = 0.0
        }
        
        return validPoint
    }
    
    // MARK: - Convenience
    
    private func cornerViews(hidden: Bool) {
        showCornerView.isHidden = true //default is hidden
        showCornerView.dotImageView.isHidden = true
        topLeftCornerView.isHidden = hidden
        topRightCornerView.isHidden = hidden
        bottomRightCornerView.isHidden = hidden
        bottomLeftCornerView.isHidden = hidden
    }
    
    private func update(_ quad: ZLQuadrilateral, withPosition position: CGPoint, forCorner corner: ZLCornerPosition) -> ZLQuadrilateral {
        var quad = quad
        
        switch corner {
        case .topLeft:
            quad.topLeft = position
        case .topRight:
            quad.topRight = position
        case .bottomRight:
            quad.bottomRight = position
        case .bottomLeft:
            quad.bottomLeft = position
        }
        
        return quad
    }
    
    func cornerViewForCornerPosition(position: ZLCornerPosition) -> ZLScanEditCornerView {
        switch position {
        case .topLeft:
            return topLeftCornerView
        case .topRight:
            return topRightCornerView
        case .bottomLeft:
            return bottomLeftCornerView
        case .bottomRight:
            return bottomRightCornerView
        }
    }
    func getQuardRect()-> CGRect{
        return CGRect(x: self.quadLayer.path?.boundingBox.origin.x ?? 0.0, y: self.quadLayer.path?.boundingBox.origin.y ?? 0.0, width: self.quadLayer.path?.boundingBox.size.width ?? 0.0, height: self.quadLayer.path?.boundingBox.size.height ?? 0.0)
    }
}