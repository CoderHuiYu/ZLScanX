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
    var dragCell : UIImageView {
        let dragCell = UIImageView()
        dragCell.contentMode = .scaleAspectFill
        dragCell.backgroundColor = UIColor.clear
        dragCell.isHidden = true
        dragCell.layer.shadowColor = UIColor.black.cgColor
        dragCell.layer.shadowRadius = 7
        dragCell.layer.shadowOpacity = 0.3
        return dragCell
    }
    
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
        if self.dragingIndexPath == nil {return}
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"BeginDrag"), object: nil)
        let cell = self.cellForItem(at: self.dragingIndexPath! as IndexPath) as! SortCollectionViewCell
        cell.iconimageView.isHidden = true
        cell.delBtn.isHidden = true
        self.dragCell.frame = cell.iconimageView.frame
        self.dragCell.isHidden = false
        self.dragCell.center = CGPoint(x: point.x, y: point.y)
        self.dragCell.image = photoModels[(self.dragingIndexPath?.row)!].image
        self.dragCell.transform = CGAffineTransform.identity
        playTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countPressTime), userInfo: nil, repeats: true)
    }
    func dragChange(_ point: CGPoint){
        if self.dragingIndexPath == nil{return}
        self.dragCell.center = CGPoint(x: point.x, y: point.y)
        self.targetIndexPath = getTargetIndexPathWithPoint(point)
        print(point)
        if point.y <= self.contentOffset.y {
            UIView.animate(withDuration: 0.5) {
                self.contentOffset = CGPoint(x: self.contentOffset.x, y: 0)
            }
        }
        if point.y > 650 {
            UIView.animate(withDuration: 0.5) {
                self.contentOffset = CGPoint(x: self.contentOffset.x, y: self.contentSize.height-kScreenHeight+kNavHeight+20)
            }
        }
        if self.dragingIndexPath != nil && self.targetIndexPath != nil{
            rankImageMutableArr()
            self.moveItem(at: self.dragingIndexPath! as IndexPath, to: self.targetIndexPath! as IndexPath)
            self.dragingIndexPath = self.targetIndexPath
        }
    }
    func dragEnd(_ point: CGPoint){
        if self.dragingIndexPath == nil{return}
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"EndDrag"), object: nil)
        let cell = self.cellForItem(at: self.dragingIndexPath! as IndexPath) as! SortCollectionViewCell
        var endFrame = cell.frame
        endFrame.origin.y = cell.frame.origin.y - self.contentOffset.y
        self.dragCell.transform = CGAffineTransform.identity
        UIView.animate(withDuration: 0.3, animations: {
            self.dragCell.frame = CGRect(x: endFrame.origin.x+10, y: endFrame.origin.y, width: cell.iconimageView.frame.width, height: cell.iconimageView.frame.height)
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
        //update cell's title text
        for i in 0 ..< self.visibleCells.count{
            let cell = self.visibleCells[i] as! SortCollectionViewCell
            cell.title.text = String( i + 1)
        }
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
        cell.configImage(iconImage: photoModels[indexPath.item].image)
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
