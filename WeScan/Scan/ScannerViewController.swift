//
//  ScannerViewController.swift
//  WeScan
//
//  Created by Boris Emorine on 2/8/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit
import AVFoundation

/// An enum used to know if the flashlight was toggled successfully.
enum FlashResult {
    case successful
    case notSuccessful
}

private let kOpenFlashCD: Double = 3

/// The `ScannerViewController` offers an interface to give feedback to the user regarding quadrilaterals that are detected. It also gives the user the opportunity to capture an image with a detected rectangle.
final class ScannerViewController: UIViewController {
    
    private var captureSessionManager: CaptureSessionManager?
    private let videoPreviewlayer = AVCaptureVideoPreviewLayer()
    
    /// The view that draws the detected rectangles.
    private let quadView = QuadrilateralView()
    
    /// Whether flash is enabled
    private var flashEnabled = false
    private var banTriggerFlash = false
    
    var isFromEdit = false
    
    var dismissWithPDFPath:((_ pdfPath: String)->())?
    var dismissCallBack: ((_ index: Int?)->())?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    let photoCollectionViewHeight: CGFloat = 150 + 44

    // takePhoto
    lazy private var shutterButton: ShutterButton = {
        let button = ShutterButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(captureImage(_:)), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    // pop
    lazy private var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("wescan.scanning.cancel", tableName: nil, bundle: Bundle(for: ScannerViewController.self), value: "Cancel", comment: "The cancel button"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelImageScannerController), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    lazy private var popButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 12, y: kNavHeight - 44, width: 100, height: 44))
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(cancelImageScannerController), for: .touchUpInside)
        button.isHidden = false
        return button
    }()
    
    // tool bar
    lazy private var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.barStyle = .blackTranslucent
        toolbar.tintColor = .white
        toolbar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        toolbar.isHidden = true
        return toolbar
    }()
    
    lazy private var autoScanButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: NSLocalizedString("wescan.scanning.auto", tableName: nil, bundle: Bundle(for: ScannerViewController.self), value: "Auto", comment: "The auto button state"), style: .plain, target: self, action: #selector(toggleAutoScan))
        return button
    }()
    
    lazy private var flashButton: UIBarButtonItem = {
        let flashImage = UIImage(named: "flash", in: Bundle(for: ScannerViewController.self), compatibleWith: nil)
        let flashButton = UIBarButtonItem(image: flashImage, style: .plain, target: self, action: #selector(toggleFlash))
        return flashButton
    }()
    
    
    lazy private var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    fileprivate lazy var photoCollectionView: ZLPhotoWaterFallView = {
        let photoCollectionView = ZLPhotoWaterFallView(frame: CGRect(x: 0, y: view.frame.height - photoCollectionViewHeight, width: view.frame.width, height: photoCollectionViewHeight))
        photoCollectionView.backViewColor = UIColor.darkGray
        
        photoCollectionView.deleteActionCallBack = { [weak self] in
            
        }
        
        photoCollectionView.selectedItemCallBack = { [weak self] (photoModels, index) in
            guard let weakSelf = self else { return }
            if  weakSelf.isFromEdit {
                if let callBack = weakSelf.dismissCallBack {
                    callBack(index)
                }
                weakSelf.dismiss(animated: true, completion: nil)
                return
            }
            if photoModels.count == 0 {
                Toast.showText("NO Image!!!")
                return
            }
            
            let vc = ZLPhotoEditorController.init(nibName: "ZLPhotoEditorController", bundle: Bundle(for: weakSelf.classForCoder))
            vc.photoModels = photoModels
            vc.currentIndex = IndexPath(item: index, section: 0)
            
            vc.updataCallBack = {
                weakSelf.photoCollectionView.getData()
            }
            vc.dismissCallBack = { (pdfPath) in
                if let callBack = weakSelf.dismissWithPDFPath {
                    callBack(pdfPath)
                }
            }
            weakSelf.captureSessionManager?.stop()
            weakSelf.navigationController?.pushViewController(vc, animated: true)
        }
        return photoCollectionView
    }()

    // Animation
    lazy var scanningNoticeImageView: UIImageView = {
        let scanningNoticeImageView = UIImageView()
        scanningNoticeImageView.frame = CGRect(x: 20, y: 7, width: 30, height: 15)
        var animationImage = [UIImage]()
        let imagePrefix = "reading_"
        let numberOfFrames = 30;
        for index in 1...numberOfFrames {
            let imageSuffix = String(format: "%.5d", index)
            let imageName = imagePrefix+imageSuffix
            guard let image = UIImage(named: imageName) else {
                return scanningNoticeImageView
            }
            animationImage.append(image)
        }
        scanningNoticeImageView.animationImages = animationImage
        scanningNoticeImageView.startAnimating()
        return scanningNoticeImageView
    }()
    
    lazy private var scanningNoticeLabel: UILabel = {
        let scanningNoticeLabel = UILabel()
        scanningNoticeLabel.frame = CGRect(x: 50, y: 5, width: 0, height: 0)
        scanningNoticeLabel.text = NSLocalizedString("wescan.scanning.notice", tableName: nil, bundle: Bundle(for: ScannerViewController.self), value: "Looking for Document", comment: "scanning notice")
        scanningNoticeLabel.font = UIFont.systemFont(ofSize: 14)
        scanningNoticeLabel.textColor = UIColor.white
        scanningNoticeLabel.sizeToFit()
        return scanningNoticeLabel
    }()
    
    lazy private var scanningNoticeView: UIView = {
        let scanningNoticeView = UIView()
        let width = 20 + scanningNoticeImageView.bounds.width + 10 + scanningNoticeLabel.bounds.width + 20
        scanningNoticeView.frame = CGRect(x: 0, y: 0, width: width, height: 30)
        scanningNoticeView.center = view.center
        scanningNoticeView.backgroundColor = UIColor.init(white: 0.4, alpha: 0.5)
        scanningNoticeView.layer.cornerRadius = 15;
        scanningNoticeView.addSubview(scanningNoticeImageView)
        scanningNoticeView.addSubview(scanningNoticeLabel)
        return scanningNoticeView
    }()
    
    lazy private var previewImageView: UIImageView  = {
        let previewImageView = UIImageView()
        previewImageView.contentMode = .scaleAspectFill
        return previewImageView
    }()
    
    
    fileprivate var disappear: Bool = false
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        title = NSLocalizedString("wescan.scanning.title", tableName: nil, bundle: Bundle(for: ScannerViewController.self), value: "Scanning", comment: "The title of the ScannerViewController")
        
        setupViews()
        setupToolbar()
        setupConstraints()
        
        captureSessionManager = CaptureSessionManager(videoPreviewLayer: videoPreviewlayer)
        captureSessionManager?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        disappear = false
        CaptureSession.current.isEditing = false
        quadView.removeQuadrilateral()
        captureSessionManager?.start()
        UIApplication.shared.isIdleTimerDisabled = true
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        videoPreviewlayer.frame = view.layer.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        disappear = true
        
        UIApplication.shared.isIdleTimerDisabled = false
        
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        if device.torchMode == .on {
            toggleFlash()
        }
    }
    
    // MARK: - Setups
    
    private func setupViews() {
        view.layer.addSublayer(videoPreviewlayer)
        quadView.translatesAutoresizingMaskIntoConstraints = false
        quadView.editable = false
        view.addSubview(quadView)
        view.addSubview(cancelButton)
        view.addSubview(shutterButton)
        view.addSubview(activityIndicator)
        view.addSubview(toolbar)
        view.addSubview(scanningNoticeView)
        view.addSubview(photoCollectionView)
        view.addSubview(previewImageView)
        
        view.addSubview(popButton)
    }
    
    private func setupToolbar() {
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([fixedSpace, flashButton, flexibleSpace, autoScanButton, fixedSpace], animated: false)
        
        if UIImagePickerController.isFlashAvailable(for: .rear) == false {
            let flashOffImage = UIImage(named: "flashUnavailable", in: Bundle(for: ScannerViewController.self), compatibleWith: nil)
            flashButton.image = flashOffImage
            flashButton.tintColor = UIColor.lightGray
        }
    }
    
    private func setupConstraints() {
        let quadViewConstraints = [
            quadView.topAnchor.constraint(equalTo: view.topAnchor),
            view.bottomAnchor.constraint(equalTo: quadView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: quadView.trailingAnchor),
            quadView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ]
        
        var cancelButtonBottomConstraint: NSLayoutConstraint
        var shutterButtonBottomConstraint: NSLayoutConstraint
        
        if #available(iOS 11.0, *) {
            cancelButtonBottomConstraint = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: (65.0 / 2) - 10.0)
            shutterButtonBottomConstraint = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: shutterButton.bottomAnchor, constant: 8.0)
        } else {
            cancelButtonBottomConstraint = view.bottomAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: (65.0 / 2) - 10.0)
            shutterButtonBottomConstraint = view.bottomAnchor.constraint(equalTo: shutterButton.bottomAnchor, constant: 8.0)
        }
        
        let cancelButtonConstraints = [
            cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24.0),
            cancelButtonBottomConstraint
            ]
        
        let shutterButtonConstraints = [
            shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shutterButtonBottomConstraint,
            shutterButton.widthAnchor.constraint(equalToConstant: 65.0),
            shutterButton.heightAnchor.constraint(equalToConstant: 65.0)
            ]
        
        let activityIndicatorConstraints = [
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(quadViewConstraints + cancelButtonConstraints + shutterButtonConstraints + activityIndicatorConstraints)
    }
    
    fileprivate func adjustScanningNoticeView() {
        scanningNoticeLabel.sizeToFit()
        let width = 20 + scanningNoticeImageView.bounds.width + 10 + scanningNoticeLabel.bounds.width + 20
        scanningNoticeView.frame = CGRect(x: 0, y: 0, width: width, height: 30)
        scanningNoticeView.center = view.center
    }
    
    // MARK: - Actions
    
    @objc private func captureImage(_ sender: UIButton) {
        let vc = SortViewController()
        self.navigationController?.pushViewController(vc, animated: true)
//        (navigationController as? ImageScannerController)?.flashToBlack()
//        shutterButton.isUserInteractionEnabled = false
//        captureSessionManager?.capturePhoto()
    }
    
    @objc private func toggleAutoScan() {
        if CaptureSession.current.autoScanEnabled {
            CaptureSession.current.autoScanEnabled = false
            autoScanButton.title = NSLocalizedString("wescan.scanning.manual", tableName: nil, bundle: Bundle(for: ScannerViewController.self), value: "Manual", comment: "The manual button state")
        } else {
            CaptureSession.current.autoScanEnabled = true
            autoScanButton.title = NSLocalizedString("wescan.scanning.auto", tableName: nil, bundle: Bundle(for: ScannerViewController.self), value: "Auto", comment: "The auto button state")
        }
    }
    
    @objc private func toggleFlash() {
        guard UIImagePickerController.isFlashAvailable(for: .rear) else { return }
        
        if flashEnabled == false && toggleTorch(toOn: true) == .successful {
            flashEnabled = true
            flashButton.tintColor = .yellow
        } else {
            flashEnabled = false
            flashButton.tintColor = .white
            
            toggleTorch(toOn: false)
        }
    }
    
    @discardableResult func toggleTorch(toOn: Bool) -> FlashResult {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video), device.hasTorch else { return .notSuccessful }
        guard (try? device.lockForConfiguration()) != nil else { return .notSuccessful }
        
        device.torchMode = toOn ? .on : .off
        device.unlockForConfiguration()
        return .successful
    }
    
    @objc private func cancelImageScannerController() {
        self.captureSessionManager?.stop()
        if isFromEdit {
            if let callBack = dismissCallBack {
                callBack(nil)
            }
            self.dismiss(animated: true, completion: nil)
        }else{
            let sure = UIAlertAction(title: "OK", style: .destructive) { _ in
                ZLPhotoModel.removeAllModel { (isSuccess) in
                    guard let imageScannerController = self.navigationController as? ImageScannerController else { return }
                    imageScannerController.imageScannerDelegate?.imageScannerControllerDidCancel(imageScannerController)
                }
            }
            let cancle = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
                
                CaptureSession.current.isEditing = false
                self.quadView.removeQuadrilateral()
                self.captureSessionManager?.start()
            }
            
            let alert = UIAlertController(title: "The image will be deleted.", message: "Are you sure?", preferredStyle: .alert)
            
            alert.addAction(cancle)
            alert.addAction(sure)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

extension ScannerViewController: RectangleDetectionDelegateProtocol {
    func startCapturingLoading(for captureSessionManager: CaptureSessionManager, currentAutoScanPassCounts: Int) {
        quadView.capturingAnnularProgressView.setProgress(progress:CGFloat((currentAutoScanPassCounts - RectangleFeaturesFunnel().startShootLoadingThreshold))/CGFloat(RectangleFeaturesFunnel().autoScanThreshold - RectangleFeaturesFunnel().startShootLoadingThreshold) , time: 0.0, animate: false)
    }
    
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didFailWithError error: Error) {
        
        activityIndicator.stopAnimating()
        shutterButton.isUserInteractionEnabled = true
        scanningNoticeView.isHidden = false

        quadView.capturingAnnularProgressView.setProgress(progress: 0.0, time: 0, animate: false)
        guard let imageScannerController = navigationController as? ImageScannerController else { return }
        imageScannerController.imageScannerDelegate?.imageScannerController(imageScannerController, didFailWithError: error)
    }
    
    func didStartCapturingPicture(for captureSessionManager: CaptureSessionManager) {
        scanningNoticeImageView.stopAnimating()
           scanningNoticeView.isHidden = true
        //        activityIndicator.startAnimating()
        shutterButton.isUserInteractionEnabled = false
    }
    
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didCapturePicture picture: UIImage, withQuad quad: Quadrilateral?) {
//        activityIndicator.stopAnimating()
        scanningNoticeImageView.stopAnimating()
        scanningNoticeView.isHidden = true
        
        let image = picture.applyingPortraitOrientation()
        
        
        let quad = quad ?? ScannerViewController.defaultQuad(forImage: image)
        
        guard let ciImage = CIImage(image: image) else {
            if let imageScannerController = navigationController as? ImageScannerController {
                let error = ImageScannerControllerError.ciImageCreation
                imageScannerController.imageScannerDelegate?.imageScannerController(imageScannerController, didFailWithError: error)
            }
            return
        }
        
        
        
        var cartesianScaledQuad = quad.toCartesian(withHeight: image.size.height)
        cartesianScaledQuad.reorganize()
        
        let filteredImage = ciImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: cartesianScaledQuad.bottomLeft),
            "inputTopRight": CIVector(cgPoint: cartesianScaledQuad.bottomRight),
            "inputBottomLeft": CIVector(cgPoint: cartesianScaledQuad.topLeft),
            "inputBottomRight": CIVector(cgPoint: cartesianScaledQuad.topRight)
            ])
        
        var uiImage: UIImage!
        
        // Let's try to generate the CGImage from the CIImage before creating a UIImage.
        if let cgImage = CIContext(options: nil).createCGImage(filteredImage, from: filteredImage.extent) {
            uiImage = UIImage(cgImage: cgImage)
        } else {
            uiImage = UIImage(ciImage: filteredImage, scale: 1.0, orientation: .up)
        }
        
        previewImageView.image = uiImage
        if uiImage.size.width == 0 || uiImage.size.height == 0 {
            return
        }
        let quadRect = CGRect(x: quadView.quadLayer.path?.boundingBox.origin.x ?? 0.0, y: quadView.quadLayer.path?.boundingBox.origin.y ?? 0.0, width: quadView.quadLayer.path?.boundingBox.size.width ?? 0.0, height: quadView.quadLayer.path?.boundingBox.size.height ?? 0.0)
        previewImageView.frame = quadRect;
        
        if let enhancedImage = uiImage.colorControImage() {
            self.previewImageView.image = enhancedImage
            self.photoCollectionView.addPhoto(image, uiImage, enhancedImage, true, quad)
        } else {
            self.photoCollectionView.addPhoto(image, uiImage, uiImage, false, quad)
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.previewImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.previewImageView.center = self.view.center
            
            
        }) { (Bool) in
            UIView.animate(withDuration: 0.5, animations: {
                self.previewImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
                // MARK: - add photo
           
                self.quadView.removeQuadrilateral()
            }) { (finish) in
                // continue to capture
                self.previewImageView.image = nil
                
                if self.disappear {
                    return
                }
                CaptureSession.current.isEditing = false
                captureSessionManager.start()
                CaptureSession.current.isPreviewing = false
            }
        }
      
        /*
        */
    }
    
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didDetectQuad quad: Quadrilateral?, _ imageSize: CGSize) {
        guard let quad = quad else {
            // If no quad has been detected, we remove the currently displayed on on the quadView.
            quadView.removeQuadrilateral()
            quadView.capturingAnnularProgressView.setProgress(progress: 0.0, time: 0, animate: false)
            return
        }
        
        scanningNoticeView.isHidden = true
        scanningNoticeImageView.stopAnimating()

        let portraitImageSize = CGSize(width: imageSize.height, height: imageSize.width)
        
        let scaleTransform = CGAffineTransform.scaleTransform(forSize: portraitImageSize, aspectFillInSize: quadView.bounds.size)
        let scaledImageSize = imageSize.applying(scaleTransform)
        
        let rotationTransform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2.0))

        let imageBounds = CGRect(origin: .zero, size: scaledImageSize).applying(rotationTransform)

        let translationTransform = CGAffineTransform.translateTransform(fromCenterOfRect: imageBounds, toCenterOfRect: quadView.bounds)
        
        let transforms = [scaleTransform, rotationTransform, translationTransform]
        
        let transformedQuad = quad.applyTransforms(transforms)
        
        quadView.drawQuadrilateral(quad: transformedQuad, animated: true)

    }
    
    func startShowingScanningNotice(noRectangle: Int) {
        scanningNoticeView.isHidden = false
        scanningNoticeImageView.startAnimating()
        if noRectangle < 100 {
            scanningNoticeLabel.text = NSLocalizedString("wescan.scanning.notice", tableName: nil, bundle: Bundle(for: ScannerViewController.self), value: "wescan.scanning.notice", comment: "normal")

        } else if noRectangle < 200 {
            scanningNoticeLabel.text = NSLocalizedString("wescan.scanning.notice.move", tableName: nil, bundle: Bundle(for: ScannerViewController.self), value: "wescan.scanning.notice.move", comment: "move")
        } else if noRectangle < 500 {
            scanningNoticeLabel.text = NSLocalizedString("wescan.scanning.notice.long", tableName: nil, bundle: Bundle(for: ScannerViewController.self), value: "wescan.scanning.notice.long", comment: "long")
        }
        adjustScanningNoticeView()
    }
    
    private static func defaultQuad(forImage image: UIImage) -> Quadrilateral {
        let topLeft = CGPoint(x: image.size.width / 3.0, y: image.size.height / 3.0)
        let topRight = CGPoint(x: 2.0 * image.size.width / 3.0, y: image.size.height / 3.0)
        let bottomRight = CGPoint(x: 2.0 * image.size.width / 3.0, y: 2.0 * image.size.height / 3.0)
        let bottomLeft = CGPoint(x: image.size.width / 3.0, y: 2.0 * image.size.height / 3.0)
        
        let quad = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
        
        return quad
    }
    
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, brightValueDidChange brightValue: Double) {
        
//        print(brightValue)
        
        if banTriggerFlash == true {
            return
        }
        
        if brightValue < -2 {
            openFlash()
        }
        
        
        if brightValue > 3 {
            closeFlash()
        }
        
        
    }
    
    
    fileprivate func openFlash() {
        guard UIImagePickerController.isFlashAvailable(for: .rear) else { return }
        
        DispatchQueue.main.async {
            if self.flashEnabled == false && self.toggleTorch(toOn: true) == .successful {
                self.flashEnabled = true
                self.flashButton.tintColor = .yellow
            }
        }
        
        banTriggerFlash = true
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + kOpenFlashCD) {
            self.banTriggerFlash = false
        }
    }
    
    fileprivate func closeFlash() {
        guard UIImagePickerController.isFlashAvailable(for: .rear) else { return }
        
        DispatchQueue.main.async {
            if self.flashEnabled == true {
                self.flashEnabled = false
                self.flashButton.tintColor = .white
                self.toggleTorch(toOn: false)
            }
        }
        
//        banTriggerFlash = true
//
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + kOpenFlashCD) {
//            self.banTriggerFlash = false
//        }
        
    }
    
}
