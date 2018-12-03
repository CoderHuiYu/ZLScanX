//
//  ZLPhotoEditorController.swift
//  WeScan
//
//  Created by apple on 2018/11/30.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit
private let kCollectionCellIdentifier = "kCollectionCellIdentifier"
private let kToolBarHeight: CGFloat = 50

class ZLPhotoEditorController: UIViewController {
    
    var photoModels = [ZLPhotoModel]()
    var currentIndex: NSInteger = 0
    
    @IBOutlet weak var customNavBar: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var toolBarView: UIView!
    
    @IBOutlet weak var toolBarViewBottomCons: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var editingView: ZLPhotoEditingView = {
        let editingView = Bundle.init(for: self.classForCoder).loadNibNamed("ZLPhotoEditingView", owner: nil, options: nil)?.first as! ZLPhotoEditingView
        editingView.frame = view.bounds
        return editingView
    }()
    
    fileprivate var isEditingStatus: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = UIColor.white
        titleLabel.text = "1/11"
        setupUI()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

}

// MARK: - UI
extension ZLPhotoEditorController {
    
    fileprivate func setupUI() {
        let layout = ZLPhotoWaterFallLayout()
        layout.minimumLineSpacing = 40
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layout.dataSource = self
        collectionView.register(UINib(nibName: "ZLPhotoCell", bundle: Bundle(for: type(of: self))), forCellWithReuseIdentifier: kCollectionCellIdentifier)
        collectionView.collectionViewLayout = layout
        
        view.addSubview(editingView)
    }
    
    fileprivate func setNavBar(isHidden: Bool) {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.customNavBar.alpha = isHidden ? 0.1 : 1.0
        }) { (_) in
            self.customNavBar.isHidden = isHidden
        }
    }
    
}

// MARK: - DataSource And Delegate
extension ZLPhotoEditorController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCollectionCellIdentifier, for: indexPath) as! ZLPhotoCell
        cell.cellType = .edit
        cell.photoModel = photoModels[indexPath.row]
        cell.itemDidRemove = { [weak self] (theCell) in
            self?.removeItem(theCell)
        }
        cell.itemBeginDrag = { [weak self] (theCell, dragStatus) in
            self?.setNavBar(isHidden: dragStatus == .begin)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
  
        setNavBar(isHidden: true)
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            let zlCell = cell as! ZLPhotoCell
            editingView.show(zlCell.imageView)
            // hide call back
            editingView.hideCallBack = { [weak self] in
                self?.setNavBar(isHidden: false)
            }
        }
    }
    
    fileprivate func removeItem(_ cell: ZLPhotoCell) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        photoModels.remove(at: indexPath.row)
        collectionView.reloadData()
    }
    
}

extension ZLPhotoEditorController: ZLPhotoWaterFallLayoutDataSource {
    
    func waterFallLayout(_ layout: ZLPhotoWaterFallLayout, indexPath: IndexPath) -> CGSize {
        let model = photoModels[indexPath.row]
        let itemWidth = collectionView.bounds.size.width - 40
        let itemHeight = getItemHeight(model.imageSize, itemWidth)
        let maxHeight = collectionView.bounds.size.height
        return CGSize(width: itemWidth, height: itemHeight > maxHeight ? maxHeight : itemHeight)
    }
    
    fileprivate func getItemHeight(_ imageSize: CGSize, _ itemWidth: CGFloat) -> CGFloat {
        return imageSize.height * itemWidth / imageSize.width
    }
}


// MARK: - Event
extension ZLPhotoEditorController {
    
    @IBAction func leftButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)

    }
    
    @IBAction func rightButtonAction(_ sender: Any) {
        
    }
}

