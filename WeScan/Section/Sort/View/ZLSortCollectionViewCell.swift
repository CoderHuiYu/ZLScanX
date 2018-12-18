//
//  ZLSortCollectionViewCell.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/17.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

protocol ZLSortCollectionViewCellProtocol: NSObjectProtocol  {
    func deleteItem(_ currentCell: ZLSortCollectionViewCell)
}

class ZLSortCollectionViewCell: UICollectionViewCell {
    static let ZLSortCollectionViewCellID = "ZLSortCollectionViewCellID"
    weak var delegate: ZLSortCollectionViewCellProtocol?
    
    lazy var iconimageView: UIImageView = {
        let iconimageView = UIImageView()
        iconimageView.contentMode = .scaleAspectFill
        iconimageView.isUserInteractionEnabled = true
        iconimageView.clipsToBounds = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapCell(_:)))
        iconimageView.addGestureRecognizer(tap)
        return iconimageView
    }()
    lazy var title: UILabel = {
        let title = UILabel()
        title.textColor = globalColor
        title.textAlignment = .center
        title.font = UIFont.boldSystemFont(ofSize: 16)
        return title
    }()
    lazy var delBtn: UIButton = {
        let delBtn = UIButton()
        let delImage = UIImage(named: "ZLS_delete", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        delBtn.setImage(delImage, for: .normal)
        delBtn.layer.cornerRadius = 11
        delBtn.backgroundColor = UIColor.white
        delBtn.addTarget(self, action: #selector(delBtnClicked(_ :)), for: .touchUpInside)
        return delBtn
    }()
    
    private lazy var imaginaryLine: UIImageView = {
        let imaginaryLine = UIImageView()
        return imaginaryLine
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(dragBegin), name: NSNotification.Name(rawValue:"ZLScanBeginDrag"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(endDrag), name: NSNotification.Name(rawValue:"ZLScanEndDrag"), object: nil)
        setupView()
    }
    
    private func setupView(){
        backgroundColor = UIColor.clear
        
        contentView.backgroundColor = UIColor.clear
        contentView.addSubview(imaginaryLine)
        contentView.addSubview(iconimageView)
        contentView.addSubview(title)
        contentView.addSubview(delBtn)
        
        title.frame = CGRect(x: 0, y: frame.height - 16, width: frame.width, height: 16)
    }
    private func addImaginaryLine(_ frame: CGRect){
        imaginaryLine.layer.sublayers?.removeAll()
        
        let border = CAShapeLayer()
        border.strokeColor = globalColor.cgColor
        border.fillColor = UIColor.clear.cgColor
        border.path = UIBezierPath(rect: CGRect(x: 1, y: 1, width: frame.size.width-2, height: frame.size.height-2)).cgPath
        border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        border.lineWidth = 1
        border.lineCap = CAShapeLayerLineCap(rawValue: "square")
        border.lineDashPattern = [6,4]
        
        imaginaryLine.layer.addSublayer(border)
    }
    
    func configImage(iconImage: UIImage){
        let itemWidth = frame.width - 40
        let size = iconImage.size
        var heigh = itemWidth * size.height / size.width
        if heigh > frame.height - 46 {
            heigh = frame.height - 46
        }
        
        let gap = (frame.height - 16 - heigh)/2 - 10
        iconimageView.frame = CGRect(x: 20, y: gap, width: itemWidth, height:heigh)
        iconimageView.image = iconImage
        imaginaryLine.frame = CGRect(x: 20, y: gap, width: itemWidth, height: heigh)
        delBtn.frame = CGRect(x: contentView.frame.size.width-31, y: gap-9, width: 22, height: 22)
        
        addImaginaryLine(iconimageView.frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//MARK: -- Action and Notification
extension ZLSortCollectionViewCell{
    @objc private func delBtnClicked(_ btn: UIButton){
        guard let delegate = delegate else { return }
        delegate.deleteItem(self)
    }
    
    @objc private func dragBegin(){
        let opts = UIView.AnimationOptions.curveEaseInOut
        UIView.animate(withDuration: 0.3, delay: 0.5, options: opts, animations: {
            self.delBtn.alpha = 0
        }, completion: nil)
    }
    
    @objc private func endDrag(){
        let opts = UIView.AnimationOptions.curveEaseInOut
        UIView.animate(withDuration: 0.7, delay: 0.5, options: opts, animations: {
            self.delBtn.alpha = 1
        }, completion: nil)
    }
    
    @objc private func tapCell(_ ges: UITapGestureRecognizer){
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
}


