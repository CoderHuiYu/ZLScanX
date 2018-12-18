//
//  ZLPhotoWaterFallView.swift
//  WaterFallCollection
//
//  Created by apple on 2018/11/29.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit


private let kToolBarViewHeight: CGFloat = 88
private let kToolBarViewWidth: CGFloat = kScreenWidth / 4

protocol ZLPhotoWaterFallViewProtocol: NSObjectProtocol {
    func selectedItem(_ models: [ZLPhotoModel], index: Int)
    func manualToggle(_ button: UIButton)
    func flashActionToggle(_ button: UIButton)
}
class ZLPhotoWaterFallView: UIView {
    
    weak var delegate: ZLPhotoWaterFallViewProtocol?
    // manual button action call back
    var manualActionCallBack: ((_ button: UIButton)->())?
    // flash button action call back
    var flashActionCallBack: ((_ button: UIButton)->())?
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
    
    // tool bar UI
    fileprivate lazy var toolBarView: UIView = {
        let toolBarView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: kToolBarViewHeight))
        toolBarView.backgroundColor = UIColor.clear
        return toolBarView
    }()
    
    fileprivate lazy var manualButton: ZLCustomButton = {
        let manualButton = ZLCustomButton(frame: CGRect(x: 0, y: 0, width: kToolBarViewWidth, height: kToolBarViewHeight))
        manualButton.setImage(UIImage(named: "zilly_capture_manual", in: Bundle.init(for: self.classForCoder), compatibleWith: nil), for: .normal)
        manualButton.setTitle("Manual", for: .normal)
        manualButton.addTarget(self, action: #selector(manualButtonAction(_:)), for: .touchUpInside)
        return manualButton
    }()
    
    fileprivate lazy var flashButton: ZLCustomButton = {
        let flashButton = ZLCustomButton(frame: CGRect(x: manualButton.frame.maxX, y: 0, width: kToolBarViewWidth, height: kToolBarViewHeight))
        flashButton.setImage(UIImage(named: "zilly_capture_flash", in: Bundle.init(for: self.classForCoder), compatibleWith: nil), for: .normal)
        flashButton.setTitle("Flash", for: .normal)
        flashButton.addTarget(self, action: #selector(flashButtonAction(_:)), for: .touchUpInside)
        return flashButton
    }()
    
    fileprivate lazy var deleteButton: ZLCustomButton = {
        let deleteButton = ZLCustomButton(frame: CGRect(x: flashButton.frame.maxX, y: 0, width: kToolBarViewWidth, height: kToolBarViewHeight))
        deleteButton.setImage(UIImage(named: "zilly_captrue_delete", in: Bundle.init(for: self.classForCoder), compatibleWith: nil), for: .normal)
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteButtonAction), for: .touchUpInside)
        return deleteButton
    }()
    
    fileprivate lazy var completeButton: ZLCustomButton = {
        let completeButton = ZLCustomButton(frame: CGRect(x: deleteButton.frame.maxX, y: 0, width: kToolBarViewWidth, height: kToolBarViewHeight))
        completeButton.setImage(UIImage(named: "zilly_capture_done", in: Bundle.init(for: self.classForCoder), compatibleWith: nil), for: .normal)
        completeButton.setTitle("Finish", for: .normal)
        completeButton.addTarget(self, action: #selector(completeButtonAction), for: .touchUpInside)
        return completeButton
    }()
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = ZLPhotoWaterFallLayout()
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .horizontal
        layout.dataSource = self
        let height: CGFloat = bounds.height - kToolBarViewHeight
        let insetHeght: CGFloat = iPhoneX ? -17 : 0
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: toolBarView.frame.maxY, width: bounds.width, height: height), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.clipsToBounds = false
        collectionView.contentInset = UIEdgeInsets(top: insetHeght, left: 0, bottom: 0, right: 0)
        collectionView.register(UINib(nibName: "ZLPhotoCell", bundle: Bundle(for: type(of: self))), forCellWithReuseIdentifier: ZLPhotoWaterFallView.kCellIdentifier)
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
        backViewColor = UIColor.darkGray
        addSubview(toolBarView)
        toolBarView.addSubview(manualButton)
        toolBarView.addSubview(flashButton)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLPhotoWaterFallView.kCellIdentifier, for: indexPath) as! ZLPhotoCell
        cell.cellType = .normal
        cell.photoModel = photoModels[indexPath.row]
        cell.itemDidRemove = { [weak self] (item) in
            self?.removeItem(item)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if photoModels.count == 0 {
            ZLScanToast.showText("NO Image!!!")
        }
        if photoModels.count > 0 {
            guard let delegate = delegate else { return }
            delegate.selectedItem(photoModels, index: indexPath.row)
            //            if let callBack = selectedItemCallBack {
            //                callBack(photoModels, indexPath.row)
            //            }
        }
    }
    
}


// MARK: - Layout
extension ZLPhotoWaterFallView: ZLPhotoWaterFallLayoutDataSource {
    
    func waterFallLayout(_ layout: ZLPhotoWaterFallLayout, indexPath: IndexPath) -> CGSize {
        let model = photoModels[indexPath.row]
        return CGSize(width: getItemWidth(model.imageSize), height: collectionView.bounds.height - (iPhoneX ? 34 : 0))
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
    
    func addPhoto(_ originalImage: UIImage, _ scannedImage: UIImage, _ enhancedImage: UIImage, _ isEnhanced: Bool, _ detectedRectangle: ZLQuadrilateral) {
        
        ZLPhotoManager.saveImage(originalImage, scannedImage, enhancedImage) { (oriPath, scanPath, enhanPath) in
            
            if let oritempPath = oriPath, let scantempPath = scanPath, let enhantempPath = enhanPath  {
                let photoModel = ZLPhotoModel.init(oritempPath, scantempPath, enhantempPath, isEnhanced, ZLPhotoManager.getRectDict(detectedRectangle))
                photoModel.save(handle: { [weak self] (isSuccess) in
                    if isSuccess {
                        self?.photoModels.append(photoModel)
                        self?.collectionView.reloadData()
                        self?.collectionView.layoutIfNeeded()
                        // scroll to bottom
                        self?.scrollToBottom()
                    }
                })
            }
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
    
    // manual
    @objc fileprivate func manualButtonAction(_ button: UIButton) {
        button.isSelected = !button.isSelected
        if let delegate = delegate {
            delegate.manualToggle(button)
        }
    }
    
    // flash
    @objc fileprivate func flashButtonAction(_ button: UIButton) {
        button.isSelected = !button.isSelected
        if let delegate = delegate {
            delegate.flashActionToggle(button)
        }
        //        if let callBack = flashActionCallBack {
        //            callBack(button)
        //        }
    }
    
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



class ZLCustomButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.titleLabel?.textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let imageView = self.imageView, let titleLabel = self.titleLabel else {
            return
        }
        self.imageView?.frame = CGRect(x: (frame.size.width - imageView.frame.size.width) * 0.5, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height)
        self.titleLabel?.frame = CGRect(x: 0, y: imageView.frame.maxY + 10, width: frame.size.width, height: titleLabel.frame.size.height)
    }
}
extension ZLPhotoWaterFallView {
    static let kCellIdentifier = "ZLPhotoCellIdentifier"
}
