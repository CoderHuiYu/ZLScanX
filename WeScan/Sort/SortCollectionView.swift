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
    var moveOffsetY: CGFloat = 0.0
    var topGap: CGFloat = 20.0
    var transY: CGFloat = 10.0
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
        
        self.backgroundColor = COLORFROMHEX(0xf7f7f7)
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
//MARk: -- UIGestureRecognizerDelegate
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
        guard let indexPath = self.indexPathForItem(at: point) else {return}
        dragingIndexPath = indexPath
        targetIndexPath  = indexPath
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"BeginDrag"), object: nil)
        let cell = self.cellForItem(at: dragingIndexPath! ) as! SortCollectionViewCell
        cell.iconimageView.isHidden = true
        cell.delBtn.isHidden = true
        dragCell.frame = cell.iconimageView.frame
        dragCell.isHidden = false
        dragCell.center = point
        dragCell.image = photoModels[(dragingIndexPath?.row)!].enhancedImage
        dragCell.transform = CGAffineTransform.identity
        playTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countPressTime), userInfo: nil, repeats: true)
    }
    func dragChange(_ point: CGPoint){
        if dragingIndexPath == nil {return}
        dragCell.center = point
        let indexPath = self.indexPathForItem(at: point)
        if indexPath != nil { self.targetIndexPath = indexPath }
        
        if point.y <=  self.contentOffset.y + topGap {
            moveOffsetY = self.contentOffset.y - transY
            if moveOffsetY < -topGap {
                moveOffsetY = -topGap
            }
            UIView.animate(withDuration: 0.3) {
                self.contentOffset = CGPoint(x: self.contentOffset.x, y: self.moveOffsetY)
            }
        }
        if point.y - self.contentOffset.y + topGap > kScreenHeight - kNavHeight {
            moveOffsetY = self.contentOffset.y + transY
            UIView.animate(withDuration: 0.3) {
                if self.moveOffsetY > self.contentSize.height - kScreenHeight - kNavHeight{
                    self.moveOffsetY = self.contentSize.height - kScreenHeight + kNavHeight
                }
                self.contentOffset = CGPoint(x: self.contentOffset.x, y:self.moveOffsetY)
            }
        }
        if dragingIndexPath != nil && targetIndexPath != nil{
            rankImageMutableArr()
            self.moveItem(at: dragingIndexPath!, to: targetIndexPath!)
            //update cell's title text
            let currentCell = self.cellForItem(at: dragingIndexPath!) as! SortCollectionViewCell
            let targetCell = self.cellForItem(at: targetIndexPath!) as! SortCollectionViewCell
            let dif = targetIndexPath!.row - dragingIndexPath!.row
            if  dif >= 2{
                let midCell1 = self.cellForItem(at: IndexPath.init(row: (dragingIndexPath?.row)! + 1, section: (dragingIndexPath?.section)!)) as! SortCollectionViewCell
                midCell1.title.text = String((dragingIndexPath?.item)! + 2)
                let midCell2 = self.cellForItem(at: IndexPath.init(row: dragingIndexPath!.row + 2, section: self.dragingIndexPath!.section)) as! SortCollectionViewCell
                midCell2.title.text = String(dragingIndexPath!.item + 3)
            }
            if dif <= -2{
                let midCell1 = self.cellForItem(at: IndexPath.init(row: (targetIndexPath?.row)! + 1, section: (targetIndexPath?.section)!)) as! SortCollectionViewCell
                midCell1.title.text = String((targetIndexPath?.item)! + 2)
                let midCell2 = self.cellForItem(at: IndexPath.init(row: targetIndexPath!.row + 2, section: self.targetIndexPath!.section)) as! SortCollectionViewCell
                midCell2.title.text = String(targetIndexPath!.item + 3)
            }
            currentCell.title.text = String((dragingIndexPath?.item)! + 1)
            targetCell.title.text = String((targetIndexPath?.item)! + 1)
            dragingIndexPath = targetIndexPath
        }
    }
    func dragEnd(_ point: CGPoint){
        if dragingIndexPath == nil{return}
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"EndDrag"), object: nil)
        let cell = self.cellForItem(at: self.dragingIndexPath! as IndexPath) as! SortCollectionViewCell
        dragCell.transform = CGAffineTransform.identity
        UIView.animate(withDuration: 0.3, animations: {
            self.dragCell.frame = CGRect(x: cell.frame.origin.x + 20, y: cell.frame.origin.y + cell.iconimageView.frame.origin.y, width: cell.iconimageView.frame.width, height: cell.iconimageView.frame.height)
        }) { (finished) in
            self.dragCell.isHidden = true
            cell.iconimageView.isHidden = false
            cell.delBtn.isHidden = false
            
        }
        cancelPress()
    }
    func rankImageMutableArr(){
        //update Models
        let cell = photoModels[(dragingIndexPath?.row)!]
        photoModels.remove(at: (dragingIndexPath?.row)!)
        photoModels.insert(cell, at: (targetIndexPath?.row)!)
    }
    @objc func countPressTime(){
        // dragging animate
        UIView.animate(withDuration: 0.7, animations: {
            self.dragCell.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
        }) { (isFinished) in
            UIView.animate(withDuration: 0.7, animations: {
                self.dragCell.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }
    // removeTimer
    func cancelPress(){
        if (playTimer != nil) {
            playTimer?.invalidate()
            playTimer = nil
        }
    }
}
//MARK: --collectionViewDelegate
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
//MARK: -- SortCollectionViewCellProtocol
extension SortCollectionView: SortCollectionViewCellProtocol{
    //removeImageFrom photoModels
    func deleteItem(_ currentCell: SortCollectionViewCell) {
        let index = self.indexPath(for: currentCell)
        photoModels.remove(at: (index?.item)!)
        self.reloadData()
    }
}
