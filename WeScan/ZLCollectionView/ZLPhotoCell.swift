//
//  ZLPhotoCell.swift
//  WaterFallCollection
//
//  Created by apple on 2018/11/29.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

private let kMinVelocity: CGFloat = -1000
private let kAnimateDuration: TimeInterval = 0.3

private let kDeleteImageViewBottomOriginalCons: CGFloat = 10
private let kDeleteImageViewBottomStartAnimateMaxValue: CGFloat = 30
private let kDeleteImageViewBottomHideMaxValue: CGFloat = 70

class ZLPhotoCell: UICollectionViewCell {

    var itemDidRemove:((_ cell: ZLPhotoCell)->())?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteImageView: UIImageView!
    
    @IBOutlet weak var deleteImageViewBottomCons: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomCons: NSLayoutConstraint!
    
    var photoModel: ZLPhotoModel? {
        didSet {
            guard let model = photoModel else { return }
            imageView.image = UIImage(data: model.imageData)
            updateToOriginalLayout(false)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateToOriginalLayout(false)
        // add panGesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

}

// MARK: - Gesture
extension ZLPhotoCell: UIGestureRecognizerDelegate {
    
    @objc fileprivate func panGestureAction(_ ges: UIPanGestureRecognizer) {
    
        let offSetPoint = ges.translation(in: self)
        
        if offSetPoint.y > 0 {
            // bug fix
            updateToOriginalLayout(false)
            return
        }
        
        updateLayout(-offSetPoint.y)
        
        if ges.state == .ended {
            let v = ges.velocity(in: self)
            print("vvvvv+++\(v.y)")
            if v.y < kMinVelocity {
                removeItem()
            } else {
                updateToOriginalLayout(true)
            }
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        let offSetPoint = pan.translation(in: self)
        if (offSetPoint.x != 0 && offSetPoint.y != 0) || offSetPoint.y == 0 || offSetPoint.y > 0 {
            return false
        } else {
            return true
        }
    }
}

// MARK: - updateUI
extension ZLPhotoCell {
    
    func updateLayout(_ offSet: CGFloat) {
        imageViewBottomCons.constant = offSet
        if offSet > kDeleteImageViewBottomStartAnimateMaxValue {
            deleteImageView.isHidden = false
            deleteImageViewBottomCons.constant = kDeleteImageViewBottomOriginalCons - (offSet - kDeleteImageViewBottomHideMaxValue) * 0.3
            if offSet < kDeleteImageViewBottomHideMaxValue {
                deleteImageView.alpha = (offSet - kDeleteImageViewBottomStartAnimateMaxValue) / (kDeleteImageViewBottomHideMaxValue - kDeleteImageViewBottomStartAnimateMaxValue)
                print(deleteImageView)
            } else {
                deleteImageView.alpha = 1.0
            }
        }
    }
    
    func updateToOriginalLayout(_ animated: Bool) {
        if animated {
            deleteImageViewBottomCons.constant = kDeleteImageViewBottomOriginalCons
            deleteImageView.isHidden = true
            deleteImageView.alpha = 0.01
            imageViewBottomCons.constant = 0
            UIView.animate(withDuration: kAnimateDuration, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: .curveEaseOut, animations: {
                self.layoutIfNeeded()
            }, completion: nil)
        } else {
            deleteImageViewBottomCons.constant = kDeleteImageViewBottomOriginalCons
            deleteImageView.isHidden = true
            deleteImageView.alpha = 0.01
            imageViewBottomCons.constant = 0
        }
    }
    
    func removeItem() {
        imageViewBottomCons.constant = -(UIScreen.main.bounds.size.height)
        UIView.animate(withDuration: kAnimateDuration) {
            self.layoutIfNeeded()
        }
        if let callBack = itemDidRemove {
            callBack(self)
        }
    }
}
