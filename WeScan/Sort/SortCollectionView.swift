//
//  SortCollectionView.swift
//  WeScan
//
//  Created by Tyoung on 2018/11/29.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

class SortCollectionView: UICollectionView ,UIGestureRecognizerDelegate{
    let sortCellID = "sortCellID"

    var dragingIndexPath: IndexPath?
    var targetIndexPath: IndexPath?
    var playTimer: Timer?
    var itemNames = ["1","2","3"]
    var dragCell :UIImageView = UIImageView()
    lazy var imagesMutableArr: [UIImage] = {
        let image: UIImage = UIImage(named: "Nebula", in: Bundle.init(for: SortCollectionView.self), compatibleWith: nil)!
        let image1: UIImage = UIImage(named: "WeScan-Banner.jpg", in: Bundle.init(for: SortCollectionView.self), compatibleWith: nil)!
        let image2: UIImage = UIImage(named: "Nebula", in: Bundle.init(for: SortCollectionView.self), compatibleWith: nil)!
        let imagesMutableArr = [image,image1,image2]
        return imagesMutableArr
    }()
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.backgroundColor = UIColor.white
        self.showsHorizontalScrollIndicator = false
        self.isScrollEnabled = false
        self.register(SortCollectionViewCell.self, forCellWithReuseIdentifier: sortCellID)
        self.delegate = self
        self.dataSource = self
        dragCell.contentMode = .scaleAspectFit
        dragCell.backgroundColor = UIColor.clear
        dragCell.isHidden = true
        self.addSubview(dragCell)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressMethod(_:)))
        longPress.delegate = self
        longPress.minimumPressDuration = 0.3
        self.addGestureRecognizer(longPress)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func longPressMethod(_ press: UILongPressGestureRecognizer){
        let point = press.location(in: self)
        switch press.state {
        case .began :
            dragBegin(point)
        case .changed :
            dragChange(point)
        case .ended :
            dragEnd(point)
        default:
            print("")
        }
    }
    func dragBegin(_ point: CGPoint){
        self.dragingIndexPath = getDragingIndexPathWithPoint(point)
        if self.dragingIndexPath == nil{return}
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"BeginDrag"), object: nil)
        let cell = self.cellForItem(at: self.dragingIndexPath! as IndexPath) as! SortCollectionViewCell
        cell.iconimageView.isHidden = true
        cell.delBtn.isHidden = true
        self.dragCell.frame = cell.frame
        self.dragCell.isHidden = false
        self.dragCell.center = CGPoint(x: point.x, y: point.y)
        self.dragCell.image = imagesMutableArr[(self.dragingIndexPath?.row)!]
        self.dragCell.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.dragCell.layer.shadowColor = UIColor.black.cgColor
        self.dragCell.layer.shadowRadius = 10
        self.dragCell.layer.shadowOpacity = 0.5
        playTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countPressTime), userInfo: nil, repeats: true)
    }
    func dragChange(_ point: CGPoint){
        if self.dragingIndexPath == nil{return}
        self.dragCell.center = CGPoint(x: point.x, y: point.y)
        self.targetIndexPath = getTargetIndexPathWithPoint(point)
        if self.dragingIndexPath != nil && self.targetIndexPath != nil{
            rankImageMutableArr()
            self.moveItem(at: self.dragingIndexPath! as IndexPath, to: self.targetIndexPath! as IndexPath)
            self.dragingIndexPath = self.targetIndexPath
        }
    }
    func dragEnd(_ point: CGPoint){
        if self.dragingIndexPath == nil{return}
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"EndDrag"), object: nil)
        var endFrame = self.cellForItem(at: self.dragingIndexPath! as IndexPath)!.frame
        endFrame.origin.y = self.contentOffset.y - endFrame.origin.y
        self.dragCell.transform = CGAffineTransform(scaleX: 1, y: 1)
        let cell = self.cellForItem(at: self.dragingIndexPath! as IndexPath) as! SortCollectionViewCell
        UIView.animate(withDuration: 0.3, animations: {
            self.dragCell.frame = endFrame
        }) { (finished) in
            self.dragCell.isHidden = true
            cell.iconimageView.isHidden = false
            cell.delBtn.isHidden = false
        }
        cancelPress()
    }
    func rankImageMutableArr(){
        let cell = imagesMutableArr[(self.dragingIndexPath?.row)!]
        imagesMutableArr.remove(at: (self.dragingIndexPath?.row)!)
        imagesMutableArr.insert(cell, at: (self.targetIndexPath?.row)!)
    }
    func getDragingIndexPathWithPoint(_ startPoint: CGPoint) -> IndexPath{
        var dragIndex: IndexPath?
        for index in self.indexPathsForVisibleItems{
            if (self.cellForItem(at: index)?.frame)!.contains(startPoint){
                if index.row == imagesMutableArr.count{
                    return dragIndex!
                }else{
                    dragIndex = index as IndexPath
                    return dragIndex!
                }
            }
        }
        return dragIndex!
    }
    func getTargetIndexPathWithPoint(_ movePoint: CGPoint) -> IndexPath? {
        var targeIndex:IndexPath?
        for index in self.indexPathsForVisibleItems{
            if index == self.dragingIndexPath {continue}
            if (self.cellForItem(at: index)?.frame.contains(movePoint))! && index.row != imagesMutableArr.count{
                targeIndex = index as IndexPath
            }
        }
        return targeIndex
    }
    func cancelPress(){
        if (playTimer != nil) {
            playTimer?.invalidate()
            playTimer = nil
        }
        print("cancel")
    }
    @objc func countPressTime(){
        UIView.animate(withDuration: 0.7, animations: {
            self.dragCell.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
        }) { (isFinished) in
            UIView.animate(withDuration: 0.7, animations: {
                self.dragCell.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }
}
extension SortCollectionView: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.imagesMutableArr.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: sortCellID, for: indexPath) as! SortCollectionViewCell
        cell.title.text = itemNames[indexPath.item]
        cell.configImage(iconImage: imagesMutableArr[indexPath.item])
        cell.delegate = self as SortCollectionViewCellProtocol
        return cell
    }
}
extension SortCollectionView: SortCollectionViewCellProtocol{
    func deleteItem(_ currentCell: SortCollectionViewCell) {
        let index = self.indexPath(for: currentCell)
        imagesMutableArr.remove(at: (index?.item)!)
        self.reloadData()
    }
}
