//
//  ZLPDFPreviewController.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/17.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit
import QuickLook

class ZLPDFPreviewController: UIViewController, QLPreviewControllerDelegate,QLPreviewControllerDataSource{
    
    private var webview: UIWebView = UIWebView()
    private var pdfPath: String?
    private var preview: QLPreviewController = QLPreviewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preview.delegate = self
        navigationController?.pushViewController(preview, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    // MARK: Delegate
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return URL.init(fileURLWithPath: pdfPath!) as QLPreviewItem
    }
}
