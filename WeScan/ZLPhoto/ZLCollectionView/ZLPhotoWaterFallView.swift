//
//  ZLPhotoWaterFallView.swift
//  WaterFallCollection
//
//  Created by apple on 2018/11/29.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit


private let kCellIdentifier = "ZLPhotoCellIdentifier"
private let kToolBarViewHeight: CGFloat = 44

class ZLPhotoWaterFallView: UIView {
    
    // remove all photo call back
    var deleteActionCallBack: (()->())?
    // selected item call back(completion: selected all and index is 0)
    var selectedItemCallBack: ((_ photoModels: [ZLPhotoModel], _ index: Int)->())?
    
    // backColor
    var backViewColor: UIColor? {
        didSet {
            guard let color = backViewColor else {
                return
            }
            collectionView.backgroundColor = color
        }
    }
    
    fileprivate var photoModels = [ZLPhotoModel]()
    
    fileprivate lazy var toolBarView: UIView = {
        let toolBarView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: kToolBarViewHeight))
        toolBarView.backgroundColor = UIColor.clear
        return toolBarView
    }()
    
    fileprivate lazy var deleteButton: UIButton = {
        let deleteButton = UIButton(frame: CGRect(x: completeButton.frame.origin.x - 5 - kToolBarViewHeight, y: 0, width: kToolBarViewHeight, height: kToolBarViewHeight))
        deleteButton.setImage(UIImage(named: "zl_deleteButton1", in: Bundle.init(for: self.classForCoder), compatibleWith: nil), for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteButtonAction), for: .touchUpInside)
        return deleteButton
    }()
    
    fileprivate lazy var completeButton: UIButton = {
        let completeButton = UIButton(frame: CGRect(x: bounds.width - 10 - kToolBarViewHeight, y: 0, width: kToolBarViewHeight, height: kToolBarViewHeight))
        completeButton.setImage(UIImage(named: "zl_capture-done", in: Bundle.init(for: self.classForCoder), compatibleWith: nil), for: .normal)
        completeButton.addTarget(self, action: #selector(completeButtonAction), for: .touchUpInside)
        return completeButton
    }()
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = ZLPhotoWaterFallLayout()
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .horizontal
        layout.dataSource = self
        let height: CGFloat = bounds.height - kToolBarViewHeight - 10
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: toolBarView.frame.maxY + 10, width: bounds.width, height: height), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.clipsToBounds = false
        collectionView.register(UINib(nibName: "ZLPhotoCell", bundle: Bundle(for: type(of: self))), forCellWithReuseIdentifier: kCellIdentifier)
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        getData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func getData() {
        ZLPhotoModel.getAllModel(handle: { (isSuccess, models) in
            if isSuccess {
                guard let models = models else { return }
                photoModels = models
                collectionView.reloadData()
            }
        })
    }
}

// MARK: - UI
extension ZLPhotoWaterFallView {
    fileprivate func setupUI() {
        addSubview(toolBarView)
        toolBarView.addSubview(deleteButton)
        toolBarView.addSubview(completeButton)
        addSubview(collectionView)
    }
    
    fileprivate func scrollToBottom() {
        
        let contentOffset = collectionView.contentSize.width - collectionView.bounds.width
        if contentOffset > 0 {
            collectionView.setContentOffset(CGPoint(x: contentOffset, y: 0), animated: true)
        }
    }
}

// MARK: - DataSouce And Delegate
extension ZLPhotoWaterFallView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellIdentifier, for: indexPath) as! ZLPhotoCell
        cell.cellType = .normal
        cell.photoModel = photoModels[indexPath.row]
        cell.itemDidRemove = { [weak self] (item) in
            self?.removeItem(item)
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let callBack = selectedItemCallBack {
            callBack(photoModels, indexPath.row)
        }
    }
    
}


// MARK: - Layout
extension ZLPhotoWaterFallView: ZLPhotoWaterFallLayoutDataSource {
    func waterFallLayout(_ layout: ZLPhotoWaterFallLayout, indexPath: IndexPath) -> CGSize {
        let model = photoModels[indexPath.row]
        return CGSize(width: getItemWidth(model.imageSize), height: collectionView.bounds.height)
    }
    
    fileprivate func getItemWidth(_ imageSize: CGSize) -> CGFloat {
        if imageSize.height == 0 {
            return 0
        }
        return imageSize.width * collectionView.bounds.height / imageSize.height
    }
}

// MARK: - Data Operation
extension ZLPhotoWaterFallView {
    
    func addPhoto(_ originalImage: UIImage, _ scannedImage: UIImage, _ enhancedImage: UIImage, _ isEnhanced: Bool, _ detectedRectangle: Quadrilateral) {
        
        ZLPhotoManager.saveImage(originalImage) { [weak self] (oriPath) in
            ZLPhotoManager.saveImage(scannedImage, handle: { [weak self] (scanPath) in
                ZLPhotoManager.saveImage(enhancedImage, handle: { [weak self] (enhanPath) in
                    if let oritempPath = oriPath, let scantempPath = scanPath, let enhantempPath = enhanPath  {
                        let photoModel = ZLPhotoModel.init(oritempPath, scantempPath, enhantempPath, isEnhanced, ZLPhotoManager.getRectDict(detectedRectangle))
                        photoModel.save(handle: { (isSuccess) in
                            if isSuccess {
                                guard let weakSelf = self else { return }
                                weakSelf.photoModels.append(photoModel)
                                weakSelf.collectionView.reloadData()
                                weakSelf.collectionView.layoutIfNeeded()
                                // scroll to bottom
                                weakSelf.scrollToBottom()
                                
                            }
                        })
                        
                    }
                })
            })
        }
        
    }
    
    fileprivate func removeItem(_ cell: ZLPhotoCell) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        photoModels[indexPath.row].remove { (isSuccess) in
            if isSuccess {
                photoModels.remove(at: indexPath.row)
                collectionView.reloadData()
            }
        }
    }
}


// MARK: - Event
extension ZLPhotoWaterFallView {
    
    // delete All
    @objc fileprivate func deleteButtonAction() {
        ZLPhotoModel.removeAllModel { (isSuccess) in
            photoModels.removeAll()
            collectionView.reloadData()
        }
    }
    
    // ccompletion
    @objc fileprivate func completeButtonAction() {
        if let callBack = selectedItemCallBack {
            callBack(photoModels, 0)
        }
    }
}
