//
//  ZLPhotoEditorController.swift
//  WeScan
//
//  Created by apple on 2018/11/30.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit
import CoreGraphics

private let kCollectionCellIdentifier = "kCollectionCellIdentifier"
private let kToolBarHeight: CGFloat = 50

class ZLPhotoEditorController: UIViewController,emitterable {
    
    var photoModels = [ZLPhotoModel]()
    var currentIndex: IndexPath?
    
    @IBOutlet weak var customNavBar: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var toolBarView: UIView!
    
    @IBOutlet weak var toolBarViewBottomCons: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var editingView: ZLPhotoEditingView = {
        let editingView = Bundle.init(for: self.classForCoder).loadNibNamed("ZLPhotoEditingView", owner: nil, options: nil)?.first as! ZLPhotoEditingView
        editingView.frame = view.bounds
        // hide call back
        editingView.hideCallBack = { [weak self] in
            self?.setNavBar(isHidden: false)
        }
        //
        editingView.toolBarItemActionCallBack = { [weak self] (index) in
            self?.editToolBarItemAction(index)
        }
        return editingView
    }()
    lazy var coverView: UIView = {
        let coverView = UIView()
        coverView.backgroundColor = UIColor.white
        coverView.alpha =  0.5
        coverView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight-160)
        return coverView
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
            currentIndex = indexPath
            editingView.show(zlCell.imageView)
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
        let itemWidth = collectionView.bounds.size.width - 160
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
        let sortVC = SortViewController()
        sortVC.photoModels = photoModels
        sortVC.delegate = self
//        navigationController?.pushViewController(sortVC, animated: true)
        self.present(sortVC, animated: true, completion: nil)
    }
    
    fileprivate func editToolBarItemAction(_ index: Int) {
        print(index)
        // index
        switch index {
        case 0:
            
            break
        case 1:
            //图片旋转
            let image = photoModels[(currentIndex?.item)!].image
//            let image = UIImage(named: "WeScan-Banner.jpg", in: Bundle.init(for: self.classForCoder), compatibleWith: nil)
            let orientaiton = UIImage.Orientation.right
            
            let newImage =  rotateImage(image, orientation:orientaiton)
            photoModels[(currentIndex?.item)!].image = newImage
            photoModels[(currentIndex?.item)!].imageSize = newImage.size
            collectionView.reloadData()
            
            break
        case 2:
        //裁剪
            let model = photoModels[(currentIndex?.item)!]
            guard let imageToEdit =  UIImage(contentsOfFile: kPhotoFileDataPath + "/\(model.originalImagePath)") else {return}
            
            let editVC = EditScanViewController(image: imageToEdit.applyingPortraitOrientation(), quad: model.detectedRectangle)
//            editVC.didEditResults = { [unowned self] results in self.results = results;
//                self.imageView.image = results.scannedImage; self.originalScannedImage = results.scannedImage }
//            editVC.didEditQuad = { [unowned self] quad in self.quad = quad }
            let navigationController = UINavigationController(rootViewController: editVC)
            present(navigationController, animated: true)
            break
        case 3:
            self.view.addSubview(self.coverView)
            start(CGPoint.init(x: coverView.center.x, y: coverView.frame.height))
            
            DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                self.stop()
                self.coverView.removeFromSuperview()
            }
            break
        default:
            break
        }
    }
    //Mark: - 翻转 image
    func rotateImage(_ image: UIImage, orientation: UIImage.Orientation) -> UIImage {

        var rotate:Double = 0.0
        var rect = CGRect.zero
        var translateX:Float = 0
        var translateY:Float = 0
        var scaleX:Float = 0
        var scaleY:Float = 0
        switch (orientation) {
        case UIImage.Orientation.left:
            rotate = .pi/2
            rect = CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width)
            translateX = 0
            translateY = Float(-rect.size.width)
            scaleY = Float(rect.size.width/rect.size.height)
            scaleX = Float(rect.size.height/rect.size.width)
            break;
        case UIImage.Orientation.right:
            rotate = 3 * .pi/2
            rect = CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width)
            translateX = Float(-rect.size.height)
            translateY = 0
            scaleY = Float(rect.size.width/rect.size.height)
            scaleX = Float(rect.size.height/rect.size.width)
            break;
        case UIImage.Orientation.down:
            rotate = .pi
            rect = CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width)
            translateX = Float(-rect.size.width)
            translateY = Float(-rect.size.height)
            break;
        default:
            rotate = 0.0
            rect = CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width)
            translateX = 0
            translateY = 0
            break;
        }
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0.0, y: rect.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.rotate(by: CGFloat(rotate))
        context.translateBy(x: CGFloat(translateX), y: CGFloat(translateY))
        
        context.scaleBy(x:CGFloat(scaleX), y:CGFloat(scaleY))
        context.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        return newImage!
       
    }
}
// MARK: -SortViewControllerProtocol
extension ZLPhotoEditorController: SortViewControllerProtocol{
    func sortDidFinished(_ photoModels: [ZLPhotoModel]) {
        self.photoModels = photoModels
        self.collectionView.reloadData()
    }
}

