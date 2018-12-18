//
//  ZLScannerViewController.swift
//  WeScan
//
//  Created by Boris Emorine on 2/8/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit
import AVFoundation

private let photoCollectionViewWithBarHeight: CGFloat = 188.0
private let photoCollectionViewHeight: CGFloat = 88.0
private let kOpenFlashCD: Double = 3
private let brightValueOpen: Double = -2
private let brightValueClose: Double = 3

/// An enum used to know if the flashlight was toggled successfully.
enum ZLScanFlashResult {
    case successful
    case notSuccessful
}

class ZLScannerViewController: ZLScannerBasicViewController {
    var isFromEdit = false
    private var captureSessionManager: CaptureSessionManager?
    
    private let videoPreviewlayer = AVCaptureVideoPreviewLayer()
    private let quadView = ZLQuadrilateralView()

    private var flashEnabled = false
    private var banTriggerFlash = false
    
    private lazy var shutterButton: ZLScanShutterButton = {
        let button = ZLScanShutterButton()
        button.isHidden = true
        button.addTarget(self, action: #selector(captureImage(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var promptView: ZLScanningPromptView = {
        let promptView = ZLScanningPromptView(frame: .zero)
        return promptView
    }()
    private lazy var previewImageView: UIImageView  = {
        let previewImageView = UIImageView()
        previewImageView.contentMode = .scaleAspectFill
        return previewImageView
    }()
    private lazy var photoCollectionView: ZLPhotoWaterFallView = {
        let photoCollectionView = ZLPhotoWaterFallView(frame: CGRect(x: 0, y: view.frame.height - kNavHeight - photoCollectionViewWithBarHeight - kBottomGap, width: view.frame.width, height: photoCollectionViewWithBarHeight + kBottomGap))
        photoCollectionView.delegate = self
        return photoCollectionView
    }()
    
    private var disappear: Bool = false
    private var isAutoCapture: Bool = false {
        didSet {
            if isAutoCapture {
                shutterButton.isHidden = true
            } else {
                shutterButton.isHidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Scanning"
        
        setupViews()
        setupConstraints()
        
        captureSessionManager = CaptureSessionManager(videoPreviewLayer: videoPreviewlayer)
        captureSessionManager?.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        disappear = false
        ZLScanCaptureSession.current.isEditing = false
        quadView.removeQuadrilateral()
        captureSessionManager?.start()
        UIApplication.shared.isIdleTimerDisabled = true
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewlayer.frame = view.layer.bounds
        videoPreviewlayer.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - photoCollectionViewHeight - kBottomGap)
        quadView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - photoCollectionViewHeight - kBottomGap)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disappear = true
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    private func setupViews() {
        view.layer.addSublayer(videoPreviewlayer)
        quadView.translatesAutoresizingMaskIntoConstraints = false
        quadView.editable = false
        
        view.addSubview(quadView)
        view.addSubview(shutterButton)
        view.addSubview(promptView)
        view.addSubview(previewImageView)
        view.addSubview(photoCollectionView)
    }
    private func setupConstraints() {
        let shutterButtonConstraints = [
            view.bottomAnchor.constraint(equalTo: shutterButton.bottomAnchor, constant: photoCollectionViewWithBarHeight + 30 + kBottomGap),
            shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shutterButton.widthAnchor.constraint(equalToConstant: 65.0),
            shutterButton.heightAnchor.constraint(equalToConstant: 65.0)
        ]
        NSLayoutConstraint.activate(shutterButtonConstraints)
    }
}
extension ZLScannerViewController: ZLScanRectangleDetectionDelegateProtocol {
    func startCapturingLoading(for captureSessionManager: CaptureSessionManager, currentAutoScanPassCounts: Int) {
        quadView.capturingRoudedProgressView.setProgress(progress:CGFloat((currentAutoScanPassCounts - ZLScanRectangleFeaturesFunnel().startShootLoadingThreshold))/CGFloat(ZLScanRectangleFeaturesFunnel().autoScanThreshold - ZLScanRectangleFeaturesFunnel().startShootLoadingThreshold) , time: 0.0, animate: false)
    }
    
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didFailWithError error: Error) {
        shutterButton.isUserInteractionEnabled = true
        promptView.isHidden = false
        quadView.capturingRoudedProgressView.setProgress(progress: 0.0, time: 0, animate: false)
    }
    
    func didStartCapturingPicture(for captureSessionManager: CaptureSessionManager) {
        promptView.scanningNoticeImageView.stopAnimating()
        promptView.isHidden = true
        shutterButton.isUserInteractionEnabled = false
    }
    
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didCapturePicture picture: UIImage, withQuad quad: ZLQuadrilateral?) {
        promptView.scanningNoticeImageView.stopAnimating()
        promptView.isHidden = true
        let image = picture.applyingPortraitOrientation()
        let quad = quad ?? ZLScannerViewController.defaultQuad(forImage: image)
        
        guard let ciImage = CIImage(image: image) else { return }
        
        var cartesianScaledQuad = quad.toCartesian(withHeight: image.size.height)
        cartesianScaledQuad.reorganize()
        
        let filteredImage = ciImage.applyingFilter("CIPerspectiveCorrection", parameters: ciImage.getFilterDict(cartesianScaledQuad))
        
        var uiImage: UIImage!
        if let cgImage = CIContext(options: nil).createCGImage(filteredImage, from: filteredImage.extent) {
            uiImage = UIImage(cgImage: cgImage)
        } else {
            uiImage = UIImage(ciImage: filteredImage, scale: 1.0, orientation: .up)
        }
        
        previewImageView.image = uiImage
        if uiImage.size.width == 0 || uiImage.size.height == 0 { return }
        previewImageView.frame = quadView.getQuardRect();
        
        guard let enhancedImage = uiImage.colorControImage() else { return }
        previewImageView.image = enhancedImage
        photoCollectionView.addPhoto(image, uiImage, enhancedImage, true, quad)
        previewAnimate { captureSessionManager.start() }
    }
    
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didDetectQuad quad: ZLQuadrilateral?, _ imageSize: CGSize) {
        guard let quad = quad else {
            quadView.removeQuadrilateral()
            quadView.capturingRoudedProgressView.setProgress(progress: 0.0, time: 0, animate: false)
            return
        }
        promptView.isHidden = true
        promptView.scanningNoticeImageView.stopAnimating()
        quadView.drawQuadrilateral(quad: getQuadrilateral(quad, imageSize: imageSize), animated: true)
    }
    
    func startShowingScanningNotice(noRectangle: Int) {
        promptView.isHidden = false
        promptView.scanningNoticeImageView.startAnimating()
    }
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, brightValueDidChange brightValue: Double) {
        if banTriggerFlash == true { return }
        if brightValue < brightValueOpen { openFlash() }
        if brightValue > brightValueClose { closeFlash() }
    }
    func previewAnimate(_ complete:@escaping (()->())){
        UIView.animate(withDuration: 0.5, animations: {
            self.previewImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.previewImageView.center = self.view.center
        }) { (_) in
            UIView.animate(withDuration: 0.5, animations: {
                self.previewImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.quadView.removeQuadrilateral()
            }) { (_) in
                // continue to capture
                self.previewImageView.image = nil
                if self.disappear {
                    return
                }
                ZLScanCaptureSession.current.isEditing = false
                ZLScanCaptureSession.current.isPreviewing = false
                complete()
            }
        }
    }
}
extension ZLScannerViewController{
    @objc private func captureImage(_ sender: UIButton) {
        navigationController?.pushViewController(ZLScanSortViewController(), animated: true)
    }
    
    @discardableResult func toggleTorch(toOn: Bool) -> ZLScanFlashResult {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video), device.hasTorch else { return .notSuccessful }
        guard (try? device.lockForConfiguration()) != nil else { return .notSuccessful }
        device.torchMode = toOn ? .on : .off
        device.unlockForConfiguration()
        return .successful
    }
    
    private func openFlash(_ isNeedCD: Bool = true) {
        guard UIImagePickerController.isFlashAvailable(for: .rear) else { return }
        DispatchQueue.main.async {
            if self.flashEnabled == false && self.toggleTorch(toOn: true) == .successful {
                self.flashEnabled = true
            }
        }
        banTriggerFlash = true
        if isNeedCD {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + kOpenFlashCD) {
                self.banTriggerFlash = false
            }
        }
    }
    private func closeFlash() {
        guard UIImagePickerController.isFlashAvailable(for: .rear) else { return }
        DispatchQueue.main.async {
            if self.flashEnabled == true {
                self.flashEnabled = false
                self.toggleTorch(toOn: false)
            }
        }
    }
    
    override func backBtnClick() {
        self.captureSessionManager?.stop()
        if isFromEdit {
            if let callBack = dismissCallBackIndex { callBack(nil) }
            dismiss(animated: true, completion: nil)
        }else{
            showAlter(title: "The image will be deleted", message: "Are you sure?", confirm: "OK", cancel: "Cancel", confirmComp: { (_) in
                ZLPhotoModel.removeAllModel { (_) in
                    self.dismiss(animated: true, completion: nil)
                }
            }) { (_) in
                ZLScanCaptureSession.current.isEditing = false
                self.quadView.removeQuadrilateral()
                self.captureSessionManager?.start()
            }
        }
    }
}
extension ZLScannerViewController: ZLPhotoWaterFallViewProtocol {
    func flashActionToggle(_ button: UIButton) {
        if button.isSelected { openFlash() } else { closeFlash() }
    }
    
    func selectedItem(_ models: [ZLPhotoModel], index: Int) {
        if  isFromEdit {
            if let callBack = dismissCallBackIndex {
                callBack(index)
            }
            dismiss(animated: true, completion: nil)
            return
        }
        let vc = ZLPhotoEditorController.init(nibName: "ZLPhotoEditorController", bundle: Bundle(for: self.classForCoder))
        vc.photoModels = models
        vc.currentIndex = IndexPath(item: index, section: 0)
        vc.updataCallBack = {
            self.photoCollectionView.getData()
        }
        vc.dismissCallBack = { (pdfPath) in
            if let callBack = self.dismissWithPDFPath { callBack(pdfPath) }
        }
        captureSessionManager?.stop()
        navigationController?.pushViewController(vc, animated: true)
    }
    func manualToggle(_ button: UIButton) {
        if button.isSelected { isAutoCapture = false } else { isAutoCapture = true }
    }
}
//MARK: GET Quadrilateral
extension ZLScannerViewController { 
    private static func defaultQuad(forImage image: UIImage) -> ZLQuadrilateral {
        let topLeft = CGPoint(x: image.size.width / 3.0, y: image.size.height / 3.0)
        let topRight = CGPoint(x: 2.0 * image.size.width / 3.0, y: image.size.height / 3.0)
        let bottomRight = CGPoint(x: 2.0 * image.size.width / 3.0, y: 2.0 * image.size.height / 3.0)
        let bottomLeft = CGPoint(x: image.size.width / 3.0, y: 2.0 * image.size.height / 3.0)
        let quad = ZLQuadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
        return quad
    }
    private func getQuadrilateral(_ quard: ZLQuadrilateral, imageSize: CGSize) -> ZLQuadrilateral{
        let portraitImageSize = CGSize(width: imageSize.height, height: imageSize.width)
        let scaleTransform = CGAffineTransform.scaleTransform(forSize: portraitImageSize, aspectFillInSize: quadView.bounds.size)
        let scaledImageSize = imageSize.applying(scaleTransform)
        let rotationTransform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2.0))
        let imageBounds = CGRect(origin: .zero, size: scaledImageSize).applying(rotationTransform)
        let translationTransform = CGAffineTransform.translateTransform(fromCenterOfRect: imageBounds, toCenterOfRect: quadView.bounds)
        let transforms = [scaleTransform, rotationTransform, translationTransform]
        let transformedQuad = quard.applyTransforms(transforms)
        return transformedQuad
    }
}
