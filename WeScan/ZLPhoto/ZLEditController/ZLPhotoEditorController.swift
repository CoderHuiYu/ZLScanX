//
//  ZLPhotoEditorController.swift
//  WeScan
//
//  Created by apple on 2018/11/30.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit
import CoreGraphics
import Photos
import QuickLook

private let kCollectionCellIdentifier = "kCollectionCellIdentifier"
private let kToolBarHeight: CGFloat = 50
private let kSaveToolBarHeight: CGFloat = 250 // 200 -> 250 is right constraint
private let kCollectionBottomConsValue: CGFloat = 170
private let kCollectionBottomConsSaveValue: CGFloat = 220
private let kRightButtonTitle = "Sort"
private let kRightButtonTitleSelectedAll = "Select All"
private let kRightButtonTitleCancleSelectedAll = "Cancel Select All"

class ZLPhotoEditorController: UIViewController,EmitterAnimate,Convertable {
    
    var photoModels = [ZLPhotoModel]()
    var currentIndex: IndexPath?
    var isFilter: Bool = false
    var pdfpath: String?
    var isNeedLoadPDF: Bool = false
    var updataCallBack:(()->())?
    
    @IBOutlet weak var customNavBar: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var toolBarView: UIView!
    
    @IBOutlet weak var toolBarViewBottomCons: NSLayoutConstraint!

    @IBOutlet weak var saveToolBarViewBottomCons: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewBottomCons: NSLayoutConstraint!
    
    @IBOutlet weak var rightNavButton: UIButton!
    
    fileprivate lazy var editingView: ZLPhotoEditingView = {
        let editingView = Bundle.init(for: self.classForCoder).loadNibNamed("ZLPhotoEditingView", owner: nil, options: nil)?.first as! ZLPhotoEditingView
        editingView.frame = view.bounds
        // hide call back
        editingView.hideCallBack = { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.setNavBar(isHidden: false)
            let visibleCells = weakSelf.collectionView.visibleCells
            visibleCells.forEach { (theCell) in
                theCell.isHidden = false
            }
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
        let gap: CGFloat = iPhoneX ? 34.0 : 0.0
        coverView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight-160 - gap)
        return coverView
    }()
    
    fileprivate lazy var proLabel: UILabel = {
        let proLabel = UILabel()
        proLabel.text = "Restore ..."
        proLabel.textColor = globalColor
        proLabel.textAlignment = .center
        proLabel.font = UIFont.boldSystemFont(ofSize: 23)
        proLabel.frame = CGRect(x: 0, y: self.view.center.y-80, width: kScreenWidth, height: 22)
        return proLabel
    }()
    fileprivate lazy var imageViewer: ImageViewer = {
        let imgViewer = ImageViewer.init()
        return imgViewer
    }()
    fileprivate lazy var addImageBtn: UIButton = {
        let addImageBtn = UIButton()
        addImageBtn.frame = CGRect(x: kScreenWidth - 34, y: kNavHeight , width: 24, height: 24)
        let image = UIImage(named: "jiahao", in: Bundle.init(for: self.classForCoder), compatibleWith: nil)
        addImageBtn.setImage(image, for: .normal)
        addImageBtn.addTarget(self, action: #selector(addImageBtnClick), for: .touchUpInside)
        addImageBtn.isHidden = true
        return addImageBtn
    }()
    fileprivate var isSavingStatus = false {
        didSet {
            if isSavingStatus {
                
                photoModels = photoModels.map({ (model) -> ZLPhotoModel in
                    var zlModel = model
                    zlModel.isSelected = true
                    return zlModel
                })
                
                rightNavButton.setTitle(kRightButtonTitleCancleSelectedAll, for: .normal)
                setSaveToolBar(isHidden: false)
                collectionView.reloadData()
                collectionViewBottomCons.constant = kCollectionBottomConsSaveValue
            } else {
                
                rightNavButton.setTitle(kRightButtonTitle, for: .normal)
                setSaveToolBar(isHidden: true)
                collectionView.reloadData()
                collectionViewBottomCons.constant = kCollectionBottomConsValue
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupUI()
        if isNeedLoadPDF {
            addImageBtn.isHidden = false
            loadPDF {(models) in
                self.photoModels = models
                self.collectionView.reloadData()
                self.titleLabel.text = "\(1)/\(models.count)"
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
}

// MARK: - UI
extension ZLPhotoEditorController {
    
    fileprivate func setupUI() {
        
        view.backgroundColor = UIColor.white
        if let currentIndex = currentIndex {
            titleLabel.text = "\(currentIndex.row + 1)/\(photoModels.count)"
        }
        
        view.clipsToBounds = true
        
        let layout = ZLPhotoWaterFallLayout()
        layout.isNeedScrollToMiddle = true
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
        layout.dataSource = self
        collectionView.register(UINib(nibName: "ZLPhotoCell", bundle: Bundle(for: type(of: self))), forCellWithReuseIdentifier: kCollectionCellIdentifier)
        collectionView.collectionViewLayout = layout
        collectionView.decelerationRate = .fast
        view.addSubview(editingView)
        view.addSubview(addImageBtn)
        guard let currentIndex = currentIndex else {
            return
        }
        
        if currentIndex.row > 0 {
            collectionView.layoutIfNeeded()
            collectionView.scrollToItem(at: currentIndex, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
        }
    }
    
    
    fileprivate func setNavBar(isHidden: Bool) {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.customNavBar.alpha = isHidden ? 0.1 : 1.0
        }) { (_) in
            self.customNavBar.isHidden = isHidden
        }
    }
    
    fileprivate func setSaveToolBar(isHidden: Bool) {
        
        if isHidden {
            saveToolBarViewBottomCons.constant = -kSaveToolBarHeight
        } else {
            saveToolBarViewBottomCons.constant = 0
        }
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

    
    fileprivate func updateTitle() {
        let cells = collectionView.visibleCells
        let centerCells = cells.filter({
            let cellCenter = collectionView.convert($0.center, to: view)
            return cellCenter.x == view.center.x
        })
        
        guard let centerCell = centerCells.first else { return }
        guard let indexPath = collectionView.indexPath(for: centerCell) else { return }
        
        titleLabel.text = "\(indexPath.row + 1)/\(photoModels.count)"
    }
    
    
    
    fileprivate func updateEditView(_ index: IndexPath, model: ZLPhotoModel) {
        
        self.photoModels[index.row] = model
        self.collectionView.reloadData()
        
        if let callBack = self.updataCallBack {
            callBack()
        }
        
        self.collectionView.layoutIfNeeded()
        guard let cell = self.collectionView.cellForItem(at: index) else {
            return
        }
        let photoCell = cell as! ZLPhotoCell
        self.editingView.update(photoCell.imageView)
    }
    
    
}

// MARK: - DataSource And Delegate
extension ZLPhotoEditorController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCollectionCellIdentifier, for: indexPath) as! ZLPhotoCell
        cell.cellType = isSavingStatus ? .saving : .edit
        cell.photoModel = photoModels[indexPath.row]
        cell.itemDidRemove = { [weak self] (theCell) in
            self?.removeItem(theCell)
        }
        cell.itemBeginDrag = { [weak self] (theCell, dragStatus) in
            self?.setNavBar(isHidden: dragStatus == .begin)
        }
        cell.itemPinch = { [weak self] (theCell) in
            self?.scaleImageView(cell)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return
        }
        
        if isSavingStatus {
            
            var model = photoModels[indexPath.row]
            model.isSelected = !model.isSelected
            photoModels[indexPath.row] = model
            let photoCell = cell as! ZLPhotoCell
            photoCell.photoModel = model
            
            let selectedModels = photoModels.filter({return $0.isSelected == true})
            if selectedModels.count == 0 {
                rightNavButton.setTitle(kRightButtonTitleSelectedAll, for: .normal)
            } else {
                rightNavButton.setTitle(kRightButtonTitleCancleSelectedAll, for: .normal)
            }
            
        } else {
            
            let center = collectionView.convert(cell.center, to: view)
            
            if center.x == view.center.x {
                
                setNavBar(isHidden: true)
                
                let photoCell = cell as! ZLPhotoCell
                currentIndex = indexPath
                editingView.show(photoCell.imageView)
                
                let visibleCells = collectionView.visibleCells
                visibleCells.forEach { (theCell) in
                    if theCell != cell {
                        theCell.isHidden = true
                    } else {
                        theCell.isHidden = false
                    }
                }
            }
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSet = scrollView.contentOffset.x
        let itemWidth = (collectionView.bounds.width - 80 + 10)
        let index = Int((offSet + itemWidth * 0.5) / itemWidth)
        titleLabel.text = "\(index + 1)/\(photoModels.count)"
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateTitle()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateTitle()
    }

    
}

extension ZLPhotoEditorController: ZLPhotoWaterFallLayoutDataSource {
    
    func waterFallLayout(_ layout: ZLPhotoWaterFallLayout, indexPath: IndexPath) -> CGSize {
        let model = photoModels[indexPath.row]
        let itemWidth = collectionView.bounds.size.width - 80
        let itemHeight = getItemHeight(model.imageSize, itemWidth)
        let maxHeight = collectionView.bounds.size.height
        return CGSize(width: itemWidth, height: itemHeight > maxHeight ? maxHeight : itemHeight)
    }
    
    fileprivate func getItemHeight(_ imageSize: CGSize, _ itemWidth: CGFloat) -> CGFloat {
        if imageSize.width <= 0 {
            return 0
        }
        return imageSize.height * itemWidth / imageSize.width
    }
}


// MARK: - Event
extension ZLPhotoEditorController {
    
    // nav leftbutton action
    @IBAction fileprivate func leftButtonAction(_ sender: Any) {
        
        if isSavingStatus {
            isSavingStatus = false
        } else {
            if isNeedLoadPDF {
                self.dismiss(animated: true, completion: nil)
            }else{
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // nav rightbutton action
    @IBAction fileprivate func rightButtonAction(_ sender: Any) {
        
        if isSavingStatus {
            
            let button = sender as! UIButton
            let title = button.titleLabel?.text ?? ""
            if title == kRightButtonTitleSelectedAll {
                rightNavButton.setTitle(kRightButtonTitleCancleSelectedAll, for: .normal)
    
                photoModels = photoModels.map { (model) -> ZLPhotoModel in
                    var zlModel = model
                    zlModel.isSelected = true
                    return zlModel
                }
                collectionView.reloadData()
                
            } else {
                rightNavButton.setTitle(kRightButtonTitleSelectedAll, for: .normal)
                
                photoModels = photoModels.map { (model) -> ZLPhotoModel in
                    var zlModel = model
                    zlModel.isSelected = false
                    return zlModel
                }
                collectionView.reloadData()
            }
            
        } else {
            let sortVC = SortViewController()
            sortVC.photoModels = photoModels
            sortVC.delegate = self
            self.present(sortVC, animated: true, completion: nil)
        }
    }
    
    // save action
    @IBAction func saveButtonAction(_ sender: Any) {
        isSavingStatus = true
    }
    
    @IBAction func saveToolBarCancleAction(_ sender: Any) {
        isSavingStatus = false
    }
    
    
    @IBAction func saveToPhotoLibrary(_ sender: Any) {
        
        let selectedModels = photoModels.filter({return $0.isSelected == true})

        selectedModels.forEach { (model) in
            let image = UIImage.init(contentsOfFile: kPhotoFileDataPath + "/\(model.enhancedImagePath)")
            UIImageWriteToSavedPhotosAlbum(image!, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
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
    
    fileprivate func editToolBarItemAction(_ index: Int) {
        print(index)
        editToolBarAction(index)
    }
    
    
    fileprivate func scaleImageView(_ cell: ZLPhotoCell) {
        let imgView = cell.imageView as UIImageView
        imageViewer.contentImages = [imgView.image!]
        let frame = UIView.getCorrectFrameFromOriginView(originView: imgView)
        imageViewer.originFrame = frame
        imageViewer.show()
    }
}


// MARK: - SortViewControllerProtocol
extension ZLPhotoEditorController: SortViewControllerProtocol{
    func sortDidFinished(_ photoModels: [ZLPhotoModel]) {
        ZLPhotoModel.sortAllModel(photoModels) { [weak self] (isSuccess) in
            if isSuccess {
                self?.photoModels = photoModels
                self?.collectionView.reloadData()
                
                if let callBack = self?.updataCallBack {
                    callBack()
                }
            }
        }
    }
}




// MARK: - edit photo
extension ZLPhotoEditorController {
    fileprivate func editToolBarAction(_ index: Int) {
        // index
        switch index {
        // delete
        case 0:
            guard let index = currentIndex else { return }
            photoModels[index.row].remove { (isSuccess) in
                if isSuccess {
                    photoModels.remove(at: index.row)
                    collectionView.reloadData()
                    
                    if let callBack = updataCallBack {
                        callBack()
                    }
                    
                    editingView.hide()
                }
            }
            
            break
        case 1:
            // image rotate
            guard let index = currentIndex else { return }
            
            let lastModel = photoModels[index.item]
            let originalImage = UIImage(contentsOfFile: kPhotoFileDataPath + "/\(lastModel.originalImagePath)") ?? lastModel.scannedImage
            let scannedImage = lastModel.scannedImage
            let enhancedImage = lastModel.enhancedImage
            
            
            let orientaiton = UIImage.Orientation.right
            
            let newOriginalImage = rotateImage(originalImage, orientation:orientaiton)
            let newScannedImage = rotateImage(scannedImage, orientation:orientaiton)
            let newEnhancedImage = rotateImage(enhancedImage, orientation:orientaiton)
            
            let newRect = rotateRect(lastModel.detectedRectangle)
            
            lastModel.replace(newOriginalImage, newScannedImage, newEnhancedImage, lastModel.isEnhanced, newRect) { [weak self] (isSuccess, model) in
                if isSuccess {
                    
                    guard let model = model else { return }
                    guard let weakSelf = self else { return }
                    
                    weakSelf.photoModels[index.item] = model
                    weakSelf.collectionView.reloadData()
                    
                    if let callBack = weakSelf.updataCallBack {
                        callBack()
                    }
                    
                    weakSelf.collectionView.layoutIfNeeded()
                    guard let cell = weakSelf.collectionView.cellForItem(at: index) else {
                        return
                    }
                    let photoCell = cell as! ZLPhotoCell
                    weakSelf.editingView.update(photoCell.imageView)
                }
            }
            break
        case 2:
            // cut
            guard let currentIndex = currentIndex else { return }
            let lastModel = photoModels[currentIndex.item]
            
            guard let imageToEdit =  UIImage(contentsOfFile: kPhotoFileDataPath + "/\(lastModel.originalImagePath)") else {return}
            
            let editVC = EditScanViewController(image: imageToEdit.applyingPortraitOrientation(), quad: lastModel.detectedRectangle)
            editVC.editCompletion = { [weak self] (result, rect) in
                lastModel.replace(result.originalImage, result.scannedImage, result.scannedImage, lastModel.isEnhanced, rect, handle: { (isSuccess, model) in
                    if isSuccess {
                        guard let model = model else { return }
                        guard let weakSelf = self else { return }
                        
                        weakSelf.updateEditView(currentIndex, model: model)
                    }
                })
            }
            let navigationController = UINavigationController(rootViewController: editVC)
            present(navigationController, animated: true)
            
            break
        case 3:
            guard let currentIndex = currentIndex else { return }
            
            self.view.addSubview(self.coverView)
            start(CGPoint.init(x: coverView.center.x, y: coverView.frame.height))
            
            let lastModel = photoModels[currentIndex.item]
            let originalImage = UIImage(contentsOfFile: kPhotoFileDataPath + "/\(lastModel.originalImagePath)") ?? lastModel.scannedImage
            let isEnhanced = lastModel.isEnhanced
            
            if isEnhanced {
                // need review - this pic don't changed
                lastModel.replace(originalImage, lastModel.scannedImage, lastModel.scannedImage, false, lastModel.detectedRectangle, handle: { (isSuccess, model) in
                    if isSuccess {
                        
                        guard let model = model else { return }
                        
                        self.updateEditView(currentIndex, model: model)
                        
                        self.stop()
                        self.coverView.removeFromSuperview()
                    } else {
                        self.stop()
                        self.coverView.removeFromSuperview()
                    }
                })
            } else {
                // need review - this pic don't changed
//                let enhancedImage = lastModel.enhancedImage.filter(name: "CIColorControls", parameters: ["inputContrast":1.35]) ?? lastModel.scannedImage
                let enhancedImage = lastModel.enhancedImage.colorControImage() ?? lastModel.scannedImage
//                enhancedImage = enhancedImage.ciConvolutionImage()
                
                lastModel.replace(originalImage, lastModel.scannedImage, enhancedImage, true, lastModel.detectedRectangle, handle: { (isSuccess, model) in
                    if isSuccess {
                        
                        guard let model = model else { return }
                        
                        self.updateEditView(currentIndex, model: model)
                        
                        self.stop()
                        self.coverView.removeFromSuperview()
                    } else {
                        self.stop()
                        self.coverView.removeFromSuperview()
                    }
                })
            }
            
            break
        default:
            break
        }
    }
    
    // rotate rect
    fileprivate func rotateRect(_ rect: Quadrilateral) -> Quadrilateral {
        
        let topLeft = rect.topLeft
        let topRight = rect.topRight
        let bottomRight = rect.bottomRight
        let bottomLeft = rect.bottomLeft
        
        let rTopLeft = bottomLeft
        let rTopRight = topLeft
        let rBottomRight = topRight
        let rBottomLeft = bottomRight
        
        let rRect = Quadrilateral(topLeft: rTopLeft, topRight: rTopRight, bottomRight: rBottomRight, bottomLeft: rBottomLeft)
        
        return rRect
        
    }
    
    // rotate iamge
    fileprivate func rotateImage(_ image: UIImage, orientation: UIImage.Orientation) -> UIImage {
        
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
extension ZLPhotoEditorController: QLPreviewControllerDataSource, QLPreviewControllerDelegate{
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return URL.init(fileURLWithPath: pdfpath!) as QLPreviewItem
    }
    // send action
    @IBAction func sendButtonAction(_ sender: Any) {
        pdfpath = convertPDF(photoModels, fileName: "temporary.pdf")
        let preVC = QLPreviewController()
        preVC.delegate = self
        preVC.dataSource = self
        self.present(preVC, animated: true, completion: nil)
    }
    @objc func image(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
        if error != nil {
            Toast.showText("save failed!")
        }else{
            Toast.showText("save success!")
        }
    }
    @objc func addImageBtnClick(){
        let scannerViewController = ScannerViewController()
        scannerViewController.isFromEdit = true
        self.present(scannerViewController, animated: true, completion: nil)
    }
}
