//
//  ZLHUD.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/6.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

class ZLHUD: UIView {

    class func showLoadingViewIn(_ view: UIView){
        let name = "Movie_play_loading_"
        let image = UIImage(named: name + "01", in: Bundle.init(for: ZLHUD.classForCoder()), compatibleWith: nil)
        let imageView = UIImageView(image: image)
        imageView.tintColor = UIColor.black
        imageView.frame = CGRect(x: 0, y: 0, width: (image?.size.width)!, height: (image?.size.height)!)
        
        let hud = ZLHUD()
        hud.showView = view
        hud.addSubview(imageView)
        view.addSubview(hud)
        hud.frame = CGRect(x: view.center.x - ((image?.size.width)!)/2, y: view.center.y, width: (image?.size.width)!, height: (image?.size.height)!)
        
        let number = 24
        var array: [UIImage] = []
        for i in 0 ..< number{
            let imageName = name + String(format: "%02d",i)
            let aImage = UIImage(named: imageName, in: Bundle.init(for: ZLHUD.classForCoder()), compatibleWith: nil)
            array.append(aImage!)
        }
        imageView.animationImages = array
        imageView.animationDuration = 1.5
        imageView.startAnimating()
    }
    var showView: UIView = UIView()
    class func hideLoadingViewIn(_ view : UIView){
        let hud = ZLHUD.HUDForView(view: view)
        guard let loadingview = hud else {return}
        loadingview.removeFromSuperview()
    }
    private class func HUDForView(view: UIView) -> ZLHUD?{
        for v in view.subviews{
            if v is ZLHUD {return (v as! ZLHUD)}
        }
        return nil
    }
}
extension UIView{
    func showLoadingView(){
        ZLHUD.showLoadingViewIn(self)
    }
    func hideLoadingView(){
        ZLHUD.hideLoadingViewIn(self)
    }
}
