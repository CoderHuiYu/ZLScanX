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
    static let SortCollectionViewCellID = "SortCollectionViewCellID"
    weak var delegate: SortCollectionViewCellProtocol?
    
    lazy var iconimageView: UIImageView = {
        let iconimageView = UIImageView()
        iconimageView.contentMode = .scaleAspectFill
        iconimageView.isUserInteractionEnabled = true
        iconimageView.clipsToBounds = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapCell(_:)))
        iconimageView.addGestureRecognizer(tap)
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
        title.font = UIFont.boldSystemFont(ofSize: 16)
        return title
    }()
    lazy var delBtn: UIButton = {
        let delBtn = UIButton()
        let delImage = UIImage(named: "zl_cancel", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        delBtn.setImage(delImage, for: .normal)
        delBtn.layer.cornerRadius = 11
        delBtn.backgroundColor = UIColor.white
        delBtn.addTarget(self, action: #selector(delBtnClicked(_ :)), for: .touchUpInside)
        return delBtn
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(dragBegin), name: NSNotification.Name(rawValue:"BeginDrag"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(endDrag), name: NSNotification.Name(rawValue:"EndDrag"), object: nil)
        setupView()
    }
    func setupView(){
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.imaginaryLine)
        self.contentView.addSubview(self.iconimageView)
//        self.contentView.addSubview(self.title)
        self.contentView.addSubview(self.delBtn)
//        self.title.frame = CGRect(x: 0, y: self.frame.height - 16, width: self.frame.width, height: 16)
    }
    func configImage(iconImage: UIImage){
        let itemWidth = self.frame.width - 40
        let size = iconImage.size
        var heigh = itemWidth * size.height / size.width
        if heigh > self.frame.height - 46 {
            heigh = self.frame.height - 46
        }
        let yyy = (self.frame.height - 16 - heigh)/2 - 10
        self.iconimageView.frame = CGRect(x: 20, y: yyy, width: itemWidth, height:heigh)
        self.iconimageView.image = iconImage
        self.imaginaryLine.frame = CGRect(x: 20, y: yyy, width: itemWidth, height: heigh)
        self.delBtn.frame = CGRect(x: 10, y: yyy-10, width: 22, height: 22)
        addImaginaryLine(self.iconimageView.frame)
    }
    @objc func tapCell(_ ges: UITapGestureRecognizer){
        UIView.animate(withDuration: 0.5, animations: {
            self.delBtn.alpha = 0.3
            self.iconimageView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            self.iconimageView.layer.shadowColor = UIColor.black.cgColor
            self.iconimageView.layer.shadowRadius = 5
            self.iconimageView.layer.shadowOpacity = 0.5
        }) { (isFinished) in
            UIView.animate(withDuration: 0.5, animations: {
                self.iconimageView.transform = CGAffineTransform.identity
                self.delBtn.alpha = 1
                self.iconimageView.layer.shadowColor = UIColor.clear.cgColor
                self.iconimageView.layer.shadowRadius = 0
                self.iconimageView.layer.shadowOpacity = 0
            }, completion: nil)
        }
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

