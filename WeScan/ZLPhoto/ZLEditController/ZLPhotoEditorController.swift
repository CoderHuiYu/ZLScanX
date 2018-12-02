//
//  ZLPhotoEditorController.swift
//  WeScan
//
//  Created by apple on 2018/11/30.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit
private let kCollectionCellIdentifier = "kCollectionCellIdentifier"
private let kOneToolBarHeight: CGFloat = 50
private let kTwoToolBarHeight: CGFloat = 150
class ZLPhotoEditorController: UIViewController {
    
    var photoModels = [ZLPhotoModel]()
    var currentIndex: NSInteger = 0
    
    @IBOutlet weak var oneToolBarViewBottomCons: NSLayoutConstraint!
    @IBOutlet weak var twoToolBarViewBottomCons: NSLayoutConstraint!
    
    
    @IBOutlet weak var customNavBar: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var oneToolBarView: UIView!
    @IBOutlet weak var twoToolBarView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

}

// MARK: - UI
extension ZLPhotoEditorController {
    
    func setupUI() {
        let layout = ZLPhotoWaterFallLayout()
        layout.minimumLineSpacing = 40
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layout.dataSource = self
        collectionView.register(UINib(nibName: "ZLPhotoCell", bundle: Bundle(for: type(of: self))), forCellWithReuseIdentifier: kCollectionCellIdentifier)
        collectionView.collectionViewLayout = layout
    }
    
    func updateUI(_ isEditing: Bool) {
        self.isEditing = isEditing
        if isEditing {
            oneToolBarViewBottomCons.constant = -kOneToolBarHeight
            twoToolBarViewBottomCons.constant = 0
            
        } else {
            oneToolBarViewBottomCons.constant = 0
            twoToolBarViewBottomCons.constant = -kTwoToolBarHeight
            
        }
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
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
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        updateUI(!self.isEditing)
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

