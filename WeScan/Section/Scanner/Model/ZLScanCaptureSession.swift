//
//  ZLScanCaptureSession.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

final class ZLScanCaptureSession {
    static let current = ZLScanCaptureSession()
    
    /// Whether the preview image is showing
    var isPreviewing: Bool
    
    /// Whether the user is past the scanning screen or not (needed to disable auto scan on other screens)
    var isEditing: Bool
    
    /// Whether auto scan is enabled or not
    var autoScanEnabled: Bool
    
    /// The orientation of the captured image
    var editImageOrientation: CGImagePropertyOrientation
    
    private init(autoScanEnabled: Bool = true, editImageOrientation: CGImagePropertyOrientation = .up) {
        self.isPreviewing = false
        self.isEditing = false
        self.autoScanEnabled = autoScanEnabled
        self.editImageOrientation = editImageOrientation
    }
    
}
