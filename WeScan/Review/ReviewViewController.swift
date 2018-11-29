//
//  ReviewViewController.swift
//  WeScan
//
//  Created by Boris Emorine on 2/25/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

/// The `ReviewViewController` offers an interface to review the image after it has been cropped and deskwed according to the passed in quadrilateral.
final class ReviewViewController: UIViewController {
    
    var enhancedImageIsAvailable = false
    var isCurrentlyDisplayingEnhancedImage = false
    
    lazy private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isOpaque = true
//        imageView.image = results.scannedImage
        imageView.image = results.scannedImage.filter(name: "CIColorControls", parameters: ["inputContrast":1.35])
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy private var editEdgesButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Edit Edges", comment: ""), for: .normal)
        button.tintColor = UIColor.white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 19)
        button.addTarget(self, action: #selector(self.editEdges), for: .touchUpInside)
        return button
    }()
    
    lazy private var editColorsButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Restore Colors", comment: ""), for: .normal)
        button.tintColor = UIColor.white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 19)
        button.addTarget(self, action: #selector(self.editColors), for: .touchUpInside)
        return button
    }()
    
    
    lazy private var doneButton: UIBarButtonItem = {
        let title = NSLocalizedString("wescan.review.button.done", tableName: nil, bundle: Bundle(for: ReviewViewController.self), value: "Done", comment: "A generic done button")
        let button = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(finishScan))
        button.tintColor = navigationController?.navigationBar.tintColor
        return button
    }()
    
    private var results: ImageScannerResults
    private var quad: Quadrilateral
    private var originalScannedImage: UIImage
    
    // MARK: - Life Cycle
    
    init(results: ImageScannerResults , quad: Quadrilateral) {
        self.results = results
        self.quad = quad
        self.originalScannedImage = results.scannedImage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        enhancedImageIsAvailable = results.enhancedImage != nil
        
        setupViews()
        setupConstraints()
        
        title = NSLocalizedString("wescan.review.title", tableName: nil, bundle: Bundle(for: ReviewViewController.self), value: "Review", comment: "The review title of the ReviewController")
        navigationItem.rightBarButtonItem = doneButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        // We only show the toolbar (with the enhance button) if the enhanced image is available.
        if enhancedImageIsAvailable {
            navigationController?.setToolbarHidden(false, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    // MARK: Setups
    
    private func setupViews() {
        view.addSubview(imageView)
        view.insertSubview(editColorsButton, aboveSubview: imageView)
        view.insertSubview(editEdgesButton, aboveSubview: imageView)
    }

    
    private func setupConstraints() {
        let imageViewConstraints = [
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: imageView.leadingAnchor)
        ]
        
        let editColorsBottomAnchor: NSLayoutConstraint = {
            if #available(iOS 11.0, *) {
                return editColorsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            } else {
                return editColorsButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                
            }
        }()
        let editColorsButtonConstraints = [
            editColorsBottomAnchor,
            editColorsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            editColorsButton.heightAnchor.constraint(equalToConstant: 65.0),
            editColorsButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/2)
        ]
        let editEdgesBottomAnchor: NSLayoutConstraint = {
            if #available(iOS 11.0, *) {
                return editEdgesButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            } else {
                return editEdgesButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                
            }
        }()
        let editEdgesButtonConstraints = [
            editEdgesBottomAnchor,
            editEdgesButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            editEdgesButton.heightAnchor.constraint(equalToConstant: 65.0),
            editEdgesButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/2)
        ]
        
        NSLayoutConstraint.activate(editColorsButtonConstraints)
        NSLayoutConstraint.activate(editEdgesButtonConstraints)
        NSLayoutConstraint.activate(imageViewConstraints)
    }
    
    // MARK: - Actions
    
    @objc private func editEdges() {
        let imageToEdit = results.originalImage
        let editVC = EditScanViewController(image: imageToEdit.applyingPortraitOrientation(), quad: quad)
        editVC.didEditResults = { [unowned self] results in self.results = results; self.imageView.image = results.scannedImage; self.originalScannedImage = results.scannedImage }
        editVC.didEditQuad = { [unowned self] quad in self.quad = quad }
        let navigationController = UINavigationController(rootViewController: editVC)
        present(navigationController, animated: true)
    }
    
    @objc private func editColors() {
        editColorsButton.isSelected = !editColorsButton.isSelected
        if editColorsButton.isSelected{
            imageView.image = results.scannedImage
            editColorsButton.setTitle("Edit Color", for: .normal)
        } else{
            imageView.image = results.scannedImage.filter(name: "CIColorControls", parameters: ["inputContrast":1.35])
            editColorsButton.setTitle("Restore Color", for: .normal)
        }
    }
    
    @objc private func finishScan() {
        guard let imageScannerController = navigationController as? ImageScannerController else { return }
        var newResults = results
        guard let resultImage = imageView.image else { return }
        newResults.scannedImage = resultImage
        imageScannerController.imageScannerDelegate?.imageScannerController(imageScannerController, didFinishScanningWithResults: newResults)
    }

}
