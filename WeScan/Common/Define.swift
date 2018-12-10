//
//  Define.swift
//  yyt_swift
//
//  Created by Tyoung on 2018/9/18.
//  Copyright © 2018年 Tyoung. All rights reserved.
//

import Foundation
import UIKit

let kScreenWidth = UIScreen.main.bounds.size.width
let kScreenHeight = UIScreen.main.bounds.size.height

let globalColor = GlobalColor()

let iPhoneX = UIScreen.main.bounds.size.height >= 812 ? true : false
let kNavHeight: CGFloat = iPhoneX ? 88.0 : 64.0
let kStatusHeight: CGFloat = iPhoneX ? 44 : 20

func RGBColor(r :CGFloat ,g:CGFloat,b:CGFloat) ->UIColor{
    return UIColor.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1);
}
func COLORFROMHEX(_ h:Int) ->UIColor {
    return RGBColor(r: CGFloat(((h)>>16) & 0xFF), g: CGFloat(((h)>>8) & 0xFF), b: CGFloat((h) & 0xFF))
}
func GlobalColor() -> UIColor{
    return COLORFROMHEX(0x18acf8)
}
