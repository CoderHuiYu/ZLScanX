//
//  ZLPhotoEditingView.swift
//  WeScan
//
//  Created by apple on 2018/12/2.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

private let kToolBarHeight: CGFloat = 150

class ZLPhotoEditingView: UIView {
    
    var hideCallBack: (()->())?
    
    var toolBarItemActionCallBack: ((_ index: Int)->())?
    
    @IBOutlet weak var toolBarView: UIView!
    @IBOutlet weak var toolBarViewBottomCons: NSLayoutConstraint!
    
    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = CGRect.zero
        return imageView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(imageView)
        isHidden = true
        toolBarViewBottomCons.constant = -kToolBarHeight
    }
    
    @IBAction fileprivate func touchAction(_ sender: Any) {
        hide()
    }
    
    func show(_ photoView: UIImageView) {
        let frame = photoView.convert(photoView.frame, to: self)
        print(frame)
        imageView.frame = frame
        imageView.image = photoView.image
        isHidden = false
        
        toolBarViewBottomCons.constant = 0
        UIView.animate(withDuration: 0.25, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    func update(_ photoView: UIImageView) {
        
        let frame = photoView.convert(photoView.frame, to: self)
        print(frame)
        imageView.frame = frame
        imageView.image = photoView.image
        
    }
    
    func hide() {
        
        if let hideCallBack = hideCallBack {
            hideCallBack()
        }
        
        toolBarViewBottomCons.constant = -kToolBarHeight
        UIView.animate(withDuration: 0.25, animations: {
            self.layoutIfNeeded()
        }, completion: { (_) in
            self.isHidden = true
        })
    }
    
    @IBAction func toolBarItemAction(_ sender: UIButton) {
        if let callBack = toolBarItemActionCallBack {
            callBack(sender.tag)
        }
    }
    
}
