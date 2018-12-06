//
//  ImageViewer.swift
//  PDImageViewer
//
//  Created by Lemonade on 2018/3/8.
//  Copyright © 2018年 Lemonade. All rights reserved.
//

import UIKit

class ImageViewer: UIView {
    // contentArray
    public var contentImages = [UIImage]()
    public var originFrame = CGRect.zero
    
    public var selectedIndex = 0
    
    var contentSC: UIScrollView?
    
    var currentZoom: CGFloat = 2.0
    
    static let kDefaultImageTag = 10000

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init(contentImages: [UIImage] = [], originFrame: CGRect = CGRect.zero) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        self.backgroundColor = UIColor.white
        self.alpha = 0.0
        
        self.contentImages = contentImages
        self.originFrame = originFrame
    
        contentSC = UIScrollView.init(frame: UIScreen.main.bounds)
        contentSC?.backgroundColor = UIColor.white
        contentSC?.isPagingEnabled = true
        contentSC?.showsHorizontalScrollIndicator = false
        contentSC?.maximumZoomScale = 4
        contentSC?.minimumZoomScale = 1
        contentSC?.zoomScale = 1.5
        contentSC?.delegate = self
        
        self.addSubview(contentSC!)
    }
    
    func show() {
        contentSC?.contentSize = CGSize.init(width: kScreenWidth * CGFloat(self.contentImages.count) , height: kScreenHeight)
        contentSC?.setContentOffset(CGPoint.init(x: CGFloat(selectedIndex) * kScreenWidth, y: 0), animated: false)
        for (index, image) in zip(0..<self.contentImages.count, self.contentImages) {
            var newImageView = contentSC?.viewWithTag(ImageViewer.kDefaultImageTag + index) as? UIImageView
            if newImageView == nil {
                newImageView = UIImageView.init(frame: CGRect.zero)
                newImageView!.tag = ImageViewer.kDefaultImageTag + index
                contentSC?.addSubview(newImageView!)
                newImageView?.isUserInteractionEnabled = true
//                let tapGR = UITapGestureRecognizer.init(target: self, action: #selector(hideImage(sender:)))
//                newImageView?.addGestureRecognizer(tapGR)
            }
            newImageView?.image = image
            if index == selectedIndex {
                newImageView?.frame = CGRect.init(x: originFrame.minX + kScreenWidth * CGFloat(index), y: originFrame.minY, width: originFrame.width, height: originFrame.height)
            } else {
                let width = kScreenWidth
                let height = width * (image.size.height / image.size.width)
                let y = (kScreenHeight - height) / 2
                let x = width * CGFloat(index)
                newImageView?.frame = CGRect.init(x: x, y: y, width: width, height: height)
            }
            
        }
        let window = UIApplication.shared.keyWindow
        window?.addSubview(self)
        
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
            let selectedView = self.contentSC?.viewWithTag(ImageViewer.kDefaultImageTag + self.selectedIndex) as? UIImageView
            let image = selectedView?.image
            let width = kScreenWidth
            let height = width * ((image?.size.height)! / (image?.size.width)!)
            let y = (kScreenHeight - height) / 2
            let x = width * CGFloat(self.selectedIndex)
            selectedView?.frame = CGRect.init(x: x, y: y, width: width, height: height)
        }

        
        
    }
    
    // Hide
    @objc func hideImage(sender: UIGestureRecognizer) {
//        if currentZoom > 1.1 {
//            return
//        }
        let selectedView = sender.view as? UIImageView
        UIView.animate(withDuration: 0.7, animations: {
            // back
            let x = self.originFrame.minX + kScreenWidth * CGFloat((selectedView?.tag)! - ImageViewer.kDefaultImageTag)
            let frame = CGRect.init(x: x, y: self.originFrame.minY, width: self.originFrame.width, height: self.originFrame.height)
            selectedView?.frame = frame
            self.alpha = 0.0
            let generatro = UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle.light)
            generatro.impactOccurred()
        }) { (completed) in
            self.removeFromSuperview()
        }
    }
}

extension UIView {
    static func getCorrectFrameFromOriginView(originView: UIView) -> CGRect {
        var correctX: CGFloat = 0
        var correctY: CGFloat = 0
        var tmpView = originView
        
        while tmpView.superview != nil {
            
            let frame = tmpView.frame
            
            
            correctX = correctX + frame.minX
            correctY = correctY + frame.minY
            
            tmpView = tmpView.superview!
            if tmpView is UIScrollView {
                let scView = tmpView as! UIScrollView
                correctX = correctX - scView.contentOffset.x
                correctY = correctY - scView.contentOffset.y
            }
        }
        correctX = correctX + tmpView.frame.minX
        correctY = correctY + tmpView.frame.minY
        
        return CGRect.init(x: correctX, y: correctY, width: originView.frame.width, height: originView.frame.height)
    }
}
extension UIImage {
    /**
     *  resetImageSize
     */
    func reSizeImage(reSize:CGSize) -> UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize, false, UIScreen.main.scale);
        self.draw(in: CGRect.init(x: 0, y: 0, width: reSize.width, height: reSize.height));
        let reSizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return reSizeImage;
    }
    
    /**
     *  scaleImage
     */
    func scaleImage(scaleSize:CGFloat) -> UIImage {
        let reSize = CGSize.init(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return reSizeImage(reSize: reSize)
    }
}
extension ImageViewer: UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentSC?.subviews.first
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        print(scrollView.zoomScale)
        currentZoom = scrollView.zoomScale
        if currentZoom <= 1 {
            let selectedView = scrollView.subviews.first as? UIImageView
            UIView.animate(withDuration: 0.3, animations: {
                let x = self.originFrame.minX + kScreenWidth * CGFloat((selectedView?.tag)! - ImageViewer.kDefaultImageTag)
                
                let frame = CGRect.init(x: x, y: self.originFrame.minY, width: self.originFrame.width, height: self.originFrame.height)
                selectedView?.frame = frame
                self.alpha = 0.0
            }) { (completed) in
                self.removeFromSuperview()
                let generatro = UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle.light)
                generatro.impactOccurred()
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
}

