//
//  ZLScanError.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/17.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

/// Errors related to the `ImageScannerController`
enum ZLScanImageScannerControllerError: Error {
    /// The user didn't grant permission to use the camera.
    case authorization
    /// An error occured when setting up the user's device.
    case inputDevice
    /// An error occured when trying to capture a picture.
    case capture
    /// Error when creating the CIImage.
    case ciImageCreation
}

extension ZLScanImageScannerControllerError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .authorization:
            return "Failed to get the user's authorization for camera."
        case .inputDevice:
            return "Could not setup input device."
        case .capture:
            return "Could not capture pitcure."
        case .ciImageCreation:
            return "Internal Error - Could not create CIImage"
        }
    }
}

