//
//  SortCollectionView.swift
//  WeScan
//
//  Created by Tyoung on 2018/11/29.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

class SortCollectionView: UICollectionView{
    var dragingIndexPath: IndexPath?
    var targetIndexPath: IndexPath?
    var playTimer: Timer?
    var photoModels = [ZLPhotoModel]()
    var cell: SortCollectionViewCell?
    var yyy = 0
    lazy var dragCell : UIImageView = {
        let dragCell = UIImageView()
        dragCell.contentMode = .scaleAspectFill
        dragCell.backgroundColor = UIColor.clear
        dragCell.isHidden = true
        dragCell.layer.shadowColor = UIColor.black.cgColor
        dragCell.layer.shadowRadius = 7
        dragCell.layer.shadowOpacity = 0.3
        return dragCell
    }()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        self.backgroundColor = UIColor.white
        self.showsHorizontalScrollIndicator = false
        self.register(SortCollectionViewCell.self, forCellWithReuseIdentifier: SortCollectionViewCell.SortCollectionViewCellID)
        self.delegate = self
        self.dataSource = self
        self.addSubview(dragCell)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressMethod(_:)))
        longPress.delegate = self
        longPress.minimumPressDuration = 0.3
        self.addGestureRecognizer(longPress)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension SortCollectionView : UIGestureRecognizerDelegate{
    @objc func longPressMethod(_ press: UILongPressGestureRecognizer){
        let point = press.location(in: self)
        switch press.state {
        case .began :
//            dragBegin(point)
            let touchP = press.location(in: self)
            guard let indexPath = self.indexPathForItem(at: touchP) else {return}
            self.dragingIndexPath = indexPath
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:"BeginDrag"), object: nil)
            let cell = self.cellForItem(at: self.dragingIndexPath! as IndexPath) as! SortCollectionViewCell
            cell.iconimageView.isHidden = true
            cell.delBtn.isHidden = true
            self.dragCell.frame = cell.iconimageView.frame
            self.dragCell.isHidden = false
            self.dragCell.center = CGPoint(x: point.x, y: point.y)
            self.dragCell.image = photoModels[(self.dragingIndexPath?.row)!].enhancedImage
            self.dragCell.transform = CGAffineTransform.identity
            playTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countPressTime), userInfo: nil, repeats: true)
            
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
        if self.dragingIndexPath == nil {return}
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"BeginDrag"), object: nil)
        let cell = self.cellForItem(at: self.dragingIndexPath! as IndexPath) as! SortCollectionViewCell
        cell.iconimageView.isHidden = true
        cell.delBtn.isHidden = true
        self.dragCell.frame = cell.iconimageView.frame
        self.dragCell.isHidden = false
        self.dragCell.center = CGPoint(x: point.x, y: point.y)
        self.dragCell.image = photoModels[(self.dragingIndexPath?.row)!].enhancedImage
        self.dragCell.transform = CGAffineTransform.identity
        playTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countPressTime), userInfo: nil, repeats: true)
    }
    func dragChange(_ point: CGPoint){
        if self.dragingIndexPath == nil{return}
        self.dragCell.center = CGPoint(x: point.x, y: point.y)
        self.targetIndexPath = getTargetIndexPathWithPoint(point)
        print(point)
        print(self.contentOffset.y)
        if point.y <=  self.contentOffset.y + 20 {
            self.yyy = Int(self.contentOffset.y - 10)
            if CGFloat(self.yyy) < -20{
                self.yyy = -20
            }
            UIView.animate(withDuration: 0.5) {
                self.contentOffset = CGPoint(x: self.contentOffset.x, y: CGFloat(self.yyy))
            }
        }
        if point.y - self.contentOffset.y + 20 > kScreenHeight - kNavHeight {
            UIView.animate(withDuration: 0.5) {
                self.yyy = Int(self.contentOffset.y + 10)
                if CGFloat(self.yyy) > self.contentSize.height - kScreenHeight - kNavHeight{
                    self.yyy = Int(self.contentSize.height - kScreenHeight + kNavHeight)
                }
                self.contentOffset = CGPoint(x: self.contentOffset.x, y:CGFloat(self.yyy))
            }
        }
        if self.dragingIndexPath != nil && self.targetIndexPath != nil{
            rankImageMutableArr()
            self.moveItem(at: self.dragingIndexPath! as IndexPath, to: self.targetIndexPath! as IndexPath)
            //update cell's title text
            let cell = self.cellForItem(at: self.dragingIndexPath!) as! SortCollectionViewCell
            let changed = self.cellForItem(at: self.targetIndexPath!) as! SortCollectionViewCell
            let dif = self.targetIndexPath!.row - self.dragingIndexPath!.row
            if  dif >= 2{
                let mid1 = self.cellForItem(at: IndexPath.init(row: (self.dragingIndexPath?.row)! + 1, section: (self.dragingIndexPath?.section)!)) as! SortCollectionViewCell
                mid1.title.text = String((self.dragingIndexPath?.item)! + 2)
                let mid2 = self.cellForItem(at: IndexPath.init(row: self.dragingIndexPath!.row + 2, section: self.dragingIndexPath!.section)) as! SortCollectionViewCell
                mid2.title.text = String(self.dragingIndexPath!.item + 3)
            }
            if dif <= -2{
                let mid1 = self.cellForItem(at: IndexPath.init(row: (self.targetIndexPath?.row)! + 1, section: (self.targetIndexPath?.section)!)) as! SortCollectionViewCell
                mid1.title.text = String((self.targetIndexPath?.item)! + 2)
                let mid2 = self.cellForItem(at: IndexPath.init(row: self.targetIndexPath!.row + 2, section: self.targetIndexPath!.section)) as! SortCollectionViewCell
                mid2.title.text = String(self.targetIndexPath!.item + 3)
            }
            cell.title.text = String((self.dragingIndexPath?.item)! + 1)
            changed.title.text = String((self.targetIndexPath?.item)! + 1)
            self.dragingIndexPath = self.targetIndexPath
        }
    }
    func dragEnd(_ point: CGPoint){
        if self.dragingIndexPath == nil{return}
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"EndDrag"), object: nil)
        let cell = self.cellForItem(at: self.dragingIndexPath! as IndexPath) as! SortCollectionViewCell
//        let endFrame = cell.frame
        self.dragCell.transform = CGAffineTransform.identity
        UIView.animate(withDuration: 0.3, animations: {
            self.dragCell.frame = CGRect(x: cell.frame.origin.x + 20, y: cell.frame.origin.y + cell.iconimageView.frame.origin.y, width: cell.iconimageView.frame.width, height: cell.iconimageView.frame.height)
//            self.dragCell.removeFromSuperview()
        }) { (finished) in
            self.dragCell.isHidden = true
            cell.iconimageView.isHidden = false
            cell.delBtn.isHidden = false
            
        }
        cancelPress()
    }
    func rankImageMutableArr(){
        //update Models
        let cell = photoModels[(self.dragingIndexPath?.row)!]
        photoModels.remove(at: (self.dragingIndexPath?.row)!)
        photoModels.insert(cell, at: (self.targetIndexPath?.row)!)
    }
    //return draging indexPath
    func getDragingIndexPathWithPoint(_ startPoint: CGPoint) -> IndexPath{
        var dragIndex: IndexPath?
        for index in self.indexPathsForVisibleItems{
            if (self.cellForItem(at: index)?.frame)!.contains(startPoint){
                if index.row == photoModels.count{
                    return dragIndex!
                }else{
                    dragIndex = index as IndexPath
                    return dragIndex!
                }
            }
        }
        return dragIndex!
    }
    //return exchanged indexPath
    func getTargetIndexPathWithPoint(_ movePoint: CGPoint) -> IndexPath? {
        var targeIndex:IndexPath?
        for index in self.indexPathsForVisibleItems{
            if index == self.dragingIndexPath {continue}
            if (self.cellForItem(at: index)?.frame.contains(movePoint))! && index.row != photoModels.count{
                targeIndex = index as IndexPath
            }
        }
        return targeIndex
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
    func cancelPress(){
        if (playTimer != nil) {
            playTimer?.invalidate()
            playTimer = nil
        }
        print("cancel")
    }
}
extension SortCollectionView: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoModels.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SortCollectionViewCell.SortCollectionViewCellID, for: indexPath) as! SortCollectionViewCell
        cell.title.text = String(indexPath.item + 1)
        cell.configImage(iconImage: photoModels[indexPath.item].enhancedImage)
        cell.delegate = self as SortCollectionViewCellProtocol
        return cell
    }
}
extension SortCollectionView: SortCollectionViewCellProtocol{
    func deleteItem(_ currentCell: SortCollectionViewCell) {
        let index = self.indexPath(for: currentCell)
        photoModels.remove(at: (index?.item)!)
        self.reloadData()
    }
}
