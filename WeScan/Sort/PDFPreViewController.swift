//
//  PDFPreViewController.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/6.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit
import QuickLook

class PDFPreViewController: UIViewController, QLPreviewControllerDelegate,QLPreviewControllerDataSource{
    
    var webview: UIWebView = UIWebView()
    var pdfPath: String?
    var preview: QLPreviewController = QLPreviewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preview.delegate = self
//        view.addSubview(webview)
//        webview.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
//        let url = URL.init(fileURLWithPath: pdfPath!)
//        let request = URLRequest.init(url: url)
//        webview.loadRequest(request)
        // Do any additional setup after loading the view.
        navigationController?.pushViewController(preview, animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return URL.init(fileURLWithPath: pdfPath!) as QLPreviewItem
    }
}
