//
//  ZLScanningPromptView.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/17.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

class ZLScanningPromptView: UIView {

    lazy var scanningNoticeImageView: UIImageView = {
        let scanningNoticeImageView = UIImageView()
        scanningNoticeImageView.frame = CGRect(x: 15, y: 7, width: 30, height: 15)
        var animationImage = [UIImage]()
        let imagePrefix = "reading_"
        let numberOfFrames = 30;
        for index in 1...numberOfFrames {
            let imageSuffix = String(format: "%.5d", index)
            let imageName = imagePrefix+imageSuffix
            guard let image = UIImage(named: imageName) else {
                return scanningNoticeImageView
            }
            animationImage.append(image)
        }
        scanningNoticeImageView.animationImages = animationImage
        scanningNoticeImageView.startAnimating()
        return scanningNoticeImageView
    }()
    lazy var scanningNoticeLabel: UILabel = {
        let scanningNoticeLabel = UILabel()
        scanningNoticeLabel.frame = CGRect(x: 50, y: 5, width: 0, height: 0)
        scanningNoticeLabel.text = "Looking for Document"
        scanningNoticeLabel.font = UIFont.systemFont(ofSize: 16)
        scanningNoticeLabel.textColor = UIColor.white
        scanningNoticeLabel.sizeToFit()
        return scanningNoticeLabel
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        //        let width = 20 + scanningNoticeImageView.bounds.width + 10 + scanningNoticeLabel.bounds.width + 20
        //        self.frame = CGRect(x: 0, y: 0, width: width, height: 30)
        self.frame = CGRect(x: 75, y: (kScreenHeight - kNavHeight)/3 - 30, width: kScreenWidth-150 , height: 30)
        backgroundColor = UIColor(white: 0.4, alpha: 0.5)
        layer.cornerRadius = 15;
        addSubview(scanningNoticeImageView)
        addSubview(scanningNoticeLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
