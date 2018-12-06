//
//  Toast.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/6.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

let ToastDispalyDuration: CGFloat = 3.0
let ToastBackgroundColor = UIColor.black

class Toast: NSObject {
    
    var _contentView: UIButton
    var _duration: CGFloat = ToastDispalyDuration
    
    init(text: String) {
        let rect = text.boundingRect(with: CGSize(width: 250, height: CGFloat.greatestFiniteMagnitude), options:[NSStringDrawingOptions.truncatesLastVisibleLine, NSStringDrawingOptions.usesFontLeading,NSStringDrawingOptions.usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
        let textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: rect.size.width + 40, height: rect.size.height + 20))
        textLabel.backgroundColor = UIColor.clear
        textLabel.textColor = UIColor.white
        textLabel.textAlignment = .center
        textLabel.font = UIFont.boldSystemFont(ofSize: 16)
        textLabel.text = text
        textLabel.numberOfLines = 0
        
        _contentView = UIButton(frame: CGRect(x: 0, y: 0, width: textLabel.frame.size.width, height: textLabel.frame.size.height))
        _contentView.layer.cornerRadius = 5.0
        _contentView.backgroundColor = ToastBackgroundColor
        _contentView.addSubview(textLabel)
        _contentView.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        super.init()
        _contentView.addTarget(self, action: #selector(toastTaped), for: .touchDown)
    }
    @objc func toastTaped(){
        self.hideAnimation()
    }
    func deviceOrientationDidChanged(notify: Notification){
        self.hideAnimation()
    }
    @objc func dismissToast(){
        _contentView.removeFromSuperview()
    }
    func setDuration(duration: CGFloat){
        _duration = duration
    }
    func showAnimation(){
        UIView.beginAnimations("show", context: nil)
        UIView.setAnimationCurve(UIView.AnimationCurve.easeIn)
        UIView.setAnimationDuration(0.3)
        _contentView.alpha = 1.0
        UIView.commitAnimations()
    }
    @objc func hideAnimation(){
        UIView.beginAnimations("hide", context: nil)
        UIView.setAnimationCurve(UIView.AnimationCurve.easeOut)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDidStop(#selector(dismissToast))
        UIView.setAnimationDuration(0.3)
        _contentView.alpha = 0.0
        UIView.commitAnimations()
    }
    
    func show(){
        let window: UIWindow = UIApplication.shared.windows.last!
//        _contentView.center = window.center //中间
//        _contentView.center = CGPoint(x: window.center.x, y: window.frame.size.height - (100 + _contentView.frame.size.height/2)) //下边
        //上面
        _contentView.center = CGPoint(x: window.center.x, y: 100 + _contentView.frame.size.height/2)
        window.addSubview(_contentView)
        self.showAnimation()
        self.perform(#selector(hideAnimation), with: nil, afterDelay: TimeInterval(_duration))
    }
    class func showText(_ text: String){
        let toast: Toast = Toast(text: text)
        toast.setDuration(duration: ToastDispalyDuration)
        toast.show()
    }
}
