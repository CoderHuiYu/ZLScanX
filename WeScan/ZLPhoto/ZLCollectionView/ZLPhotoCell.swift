//
//  ZLPhotoCell.swift
//  WaterFallCollection
//
//  Created by apple on 2018/11/29.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

private let kMinVelocity: CGFloat = -700
let kPhotoCellAnimateDuration: TimeInterval = 0.3

private let kDeleteImageViewBottomOriginalCons: CGFloat = 10
private let kDeleteImageViewBottomStartAnimateMaxValue: CGFloat = 30
private let kDeleteImageViewBottomHideMaxValue: CGFloat = 70

private let kDeleteImageViewBottomOriginalConsEditing: CGFloat = -30

enum ZLPhotoCellType {
    case normal
    case edit
}

enum DragStatus {
    case begin
    case end
}

class ZLPhotoCell: UICollectionViewCell {

    var itemDidRemove:((_ cell: ZLPhotoCell)->())?
    var itemBeginDrag:((_ cell: ZLPhotoCell, _ status: DragStatus)->())?
    
    var photoModel: ZLPhotoModel? {
        didSet {
            guard let model = photoModel else { return }
            imageView.image = model.image
            updateToOriginalLayout(false)
        }
    }
    
    var cellType: ZLPhotoCellType = .normal {
        didSet {
            if cellType == .edit {
                editImageView.isHidden = false
                deleteImageViewBottomCons.constant = kDeleteImageViewBottomOriginalConsEditing
            } else {
                editImageView.isHidden = true
                deleteImageViewBottomCons.constant = kDeleteImageViewBottomOriginalCons
            }
        }
    }
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteImageView: UIImageView!
    @IBOutlet weak var editImageView: UIImageView!
    
    @IBOutlet weak var deleteImageViewBottomCons: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomCons: NSLayoutConstraint!
    
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
        
        // begin drag call back
        if ges.state == .began {
            if let dragCallBack = itemBeginDrag {
                dragCallBack(self, .begin)
            }
        }
        
        if offSetPoint.y > 0 {
            // bug fix
            updateToOriginalLayout(false)
            return
        }
        
        updateLayout(-offSetPoint.y)
        
        if ges.state == .ended {
            
            let v = ges.velocity(in: self)
//            print("vvvvv+++\(v.y)")
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
    
    fileprivate func updateLayout(_ offSet: CGFloat) {
        imageViewBottomCons.constant = offSet
        if offSet > kDeleteImageViewBottomStartAnimateMaxValue {
            deleteImageView.isHidden = false
            if cellType == .normal {
                deleteImageViewBottomCons.constant = kDeleteImageViewBottomOriginalCons - (offSet - kDeleteImageViewBottomHideMaxValue) * 0.3
            }
            if offSet < kDeleteImageViewBottomHideMaxValue {
                deleteImageView.alpha = (offSet - kDeleteImageViewBottomStartAnimateMaxValue) / (kDeleteImageViewBottomHideMaxValue - kDeleteImageViewBottomStartAnimateMaxValue)
            } else {
                deleteImageView.alpha = 1.0
            }
        }
    }
    
    fileprivate func updateToOriginalLayout(_ animated: Bool) {
        if animated {
            deleteImageViewBottomCons.constant = cellType == .normal ? kDeleteImageViewBottomOriginalCons : kDeleteImageViewBottomOriginalConsEditing
            deleteImageView.isHidden = true
            deleteImageView.alpha = 0.01
            imageViewBottomCons.constant = 0
            UIView.animate(withDuration: kPhotoCellAnimateDuration, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: .curveEaseOut, animations: {
                self.layoutIfNeeded()
            }, completion: { _ in
                if let dragCallBack = self.itemBeginDrag {
                    dragCallBack(self, .end)
                }
            })
        } else {
            deleteImageViewBottomCons.constant = cellType == .normal ? kDeleteImageViewBottomOriginalCons : kDeleteImageViewBottomOriginalConsEditing
            deleteImageView.isHidden = true
            deleteImageView.alpha = 0.01
            imageViewBottomCons.constant = 0
            
            if let dragCallBack = itemBeginDrag {
                dragCallBack(self, .end)
            }
        }
    }
    
    fileprivate func removeItem() {
        imageViewBottomCons.constant = UIScreen.main.bounds.size.height
        UIView.animate(withDuration: kPhotoCellAnimateDuration - 0.15, animations: {
            self.layoutIfNeeded()
        }) { (_) in
            
            // remove item call back
            if let callBack = self.itemDidRemove {
                callBack(self)
            }
            
            // drag end call back
            if let dragCallBack = self.itemBeginDrag {
                dragCallBack(self, .end)
            }
        }
        
    }
}