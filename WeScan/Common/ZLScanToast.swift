//
//  ZLScanToast.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

private let ToastDispalyDuration: CGFloat = 3.0
private let ToastBackgroundColor = UIColor.black

class ZLScanToast: NSObject {
    
    private var contentView: UIButton
    private var duration: CGFloat = ToastDispalyDuration
    
    init(text: String) {
        let rect = text.boundingRect(with: CGSize(width: 250, height: CGFloat.greatestFiniteMagnitude), options:[NSStringDrawingOptions.truncatesLastVisibleLine, NSStringDrawingOptions.usesFontLeading,NSStringDrawingOptions.usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
        let textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: rect.size.width + 40, height: rect.size.height + 20))
        textLabel.backgroundColor = UIColor.clear
        textLabel.textColor = UIColor.white
        textLabel.textAlignment = .center
        textLabel.font = UIFont.boldSystemFont(ofSize: 16)
        textLabel.text = text
        textLabel.numberOfLines = 0
        
        contentView = UIButton(frame: CGRect(x: 0, y: 0, width: textLabel.frame.size.width, height: textLabel.frame.size.height))
        contentView.layer.cornerRadius = 5.0
        contentView.backgroundColor = ToastBackgroundColor
        contentView.addSubview(textLabel)
        contentView.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        super.init()
        contentView.addTarget(self, action: #selector(toastTaped), for: .touchDown)
    }
    
    class func showText(_ text: String){
        let toast: ZLScanToast = ZLScanToast(text: text)
        toast.setDuration(duration: ToastDispalyDuration)
        toast.show()
    }
    
    private func deviceOrientationDidChanged(notify: Notification){
        self.hideAnimation()
    }
    
    private func setDuration(duration: CGFloat){
        self.duration = duration
    }
    
    private func showAnimation(){
        UIView.beginAnimations("show", context: nil)
        UIView.setAnimationCurve(UIView.AnimationCurve.easeIn)
        UIView.setAnimationDuration(0.3)
        contentView.alpha = 1.0
        UIView.commitAnimations()
    }
    
    private func show(){
        let window: UIWindow = UIApplication.shared.windows.last!
        //        _contentView.center = window.center //中间
        //        _contentView.center = CGPoint(x: window.center.x, y: window.frame.size.height - (100 + _contentView.frame.size.height/2)) //下边
        //上面
        contentView.center = CGPoint(x: window.center.x, y: 100 + contentView.frame.size.height/2)
        window.addSubview(contentView)
        self.showAnimation()
        self.perform(#selector(hideAnimation), with: nil, afterDelay: TimeInterval(duration))
    }
    
    @objc private func toastTaped(){
        self.hideAnimation()
    }

    @objc private func dismissToast(){
        contentView.removeFromSuperview()
    }
    
    @objc private func hideAnimation(){
        UIView.beginAnimations("hide", context: nil)
        UIView.setAnimationCurve(UIView.AnimationCurve.easeOut)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDidStop(#selector(dismissToast))
        UIView.setAnimationDuration(0.3)
        contentView.alpha = 0.0
        UIView.commitAnimations()
    }
}

