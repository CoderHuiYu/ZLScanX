//
//  SortCollectionViewCell.swift
//  WeScan
//
//  Created by Tyoung on 2018/11/29.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

protocol SortCollectionViewCellProtocol: NSObjectProtocol  {
    func deleteItem(_ currentCell: SortCollectionViewCell)
}
class SortCollectionViewCell: UICollectionViewCell {
    weak var delegate: SortCollectionViewCellProtocol?
    lazy var iconimageView: UIImageView = {
        let iconimageView = UIImageView()
        iconimageView.contentMode = .scaleAspectFill
        iconimageView.isUserInteractionEnabled = true
        return iconimageView
    }()
    lazy var imaginaryLine: UIImageView = {
        let imaginaryLine = UIImageView()
        return imaginaryLine
    }()
    lazy var title: UILabel = {
        let title = UILabel()
        title.textColor = RGBColor(r: 80, g: 165, b: 195)
        title.textAlignment = .center
        return title
    }()
    lazy var delBtn: UIButton = {
        let delBtn = UIButton()
        let delImage = UIImage(named: "XNormal_18x18_", in: Bundle(for: SortCollectionViewCell.self), compatibleWith: nil)
        delBtn.setImage(delImage, for: .normal)
        delBtn.layer.cornerRadius = 11
        delBtn.layer.borderWidth = 1
        delBtn.layer.borderColor = RGBColor(r: 80, g: 165, b: 195).cgColor
        delBtn.layer.masksToBounds = true
        delBtn.backgroundColor = UIColor.white
        delBtn.addTarget(self, action: #selector(delBtnClicked(_ :)), for: .touchUpInside)
        return delBtn
    }()
    lazy var imageViewer: ImageViewer = {
        let imgViewer = ImageViewer.init()
        return imgViewer
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(dragBegin), name: NSNotification.Name(rawValue:"BeginDrag"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(endDrag), name: NSNotification.Name(rawValue:"EndDrag"), object: nil)
        setupView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapCell(_:)))
        iconimageView.addGestureRecognizer(tap)
    }
    func setupView(){
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.imaginaryLine)
        self.contentView.addSubview(self.iconimageView)
        self.contentView.addSubview(self.title)
        self.contentView.addSubview(self.delBtn)
        self.title.frame = CGRect(x: 0, y: self.frame.height-10, width: self.frame.width, height: 22)
    }
    func configImage(iconImage: UIImage){
        let size = iconImage.size
        var heigh = self.frame.width * size.height / size.width
        if heigh > self.frame.height - 40 {
            heigh = self.frame.height - 40
        }
        let yyy = (self.frame.height - 25 - heigh)/2
        self.iconimageView.frame = CGRect(x: 12, y: yyy+12, width: self.frame.width-12, height:heigh)
        self.iconimageView.image = iconImage
        self.imaginaryLine.frame = CGRect(x: 12, y: yyy+12, width: self.frame.width-12, height: heigh)
        self.delBtn.frame = CGRect(x: 0, y: yyy, width: 22, height: 22)
        addImaginaryLine(self.iconimageView.frame)
    }
    @objc func tapCell(_ ges: UITapGestureRecognizer){
        let imgView = ges.view as! UIImageView
        imageViewer.contentImages = [imgView.image!]
        let frame = UIView.getCorrectFrameFromOriginView(originView: imgView)
        imageViewer.originFrame = frame
        imageViewer.show()
//        UIView.animate(withDuration: 0.5, animations: {
//            self.delBtn.alpha = 0.3
//            self.iconimageView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
//            self.iconimageView.layer.shadowColor = UIColor.black.cgColor
//            self.iconimageView.layer.shadowRadius = 5
//            self.iconimageView.layer.shadowOpacity = 0.5
//        }) { (isFinished) in
//            UIView.animate(withDuration: 0.5, animations: {
//                self.iconimageView.transform = CGAffineTransform.identity
//                self.delBtn.alpha = 1
//                self.iconimageView.layer.shadowColor = UIColor.clear.cgColor
//                self.iconimageView.layer.shadowRadius = 0
//                self.iconimageView.layer.shadowOpacity = 0
//            }, completion: nil)
//        }
    }
    @objc func delBtnClicked(_ btn: UIButton){
        if self.delegate != nil{
            self.delegate?.deleteItem(self)
        }
    }
    @objc func dragBegin(){
        let opts = UIView.AnimationOptions.curveEaseInOut
        UIView.animate(withDuration: 0.3, delay: 0.5, options: opts, animations: {
            self.delBtn.alpha = 0
        }, completion: nil)
    }
    @objc func endDrag(){
        let opts = UIView.AnimationOptions.curveEaseInOut
        UIView.animate(withDuration: 0.7, delay: 0.5, options: opts, animations: {
            self.delBtn.alpha = 1
        }, completion: nil)
    }
    func addImaginaryLine(_ frame: CGRect){
        self.imaginaryLine.layer.sublayers?.removeAll()
        let border = CAShapeLayer()
        border.strokeColor = RGBColor(r: 80, g: 165, b: 195).cgColor
        border.fillColor = UIColor.clear.cgColor
        border.path = UIBezierPath(rect: CGRect(x: 0.5, y: 0.5, width: frame.size.width-1, height: frame.size.height-1)).cgPath
        border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        border.lineWidth = 1
        border.lineCap = CAShapeLayerLineCap(rawValue: "square")
        border.lineDashPattern = [6,4]
        self.imaginaryLine.layer.addSublayer(border)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

