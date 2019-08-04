//
//  UIColor+Extensions.swift
//  AnYou
//
//  Created by Leo on 2017/3/4.
//  Copyright © 2017年 binea. All rights reserved.
//

import UIKit

public extension UIColor {
    public class func from(hexString: String, alpha: CGFloat = 1.0) -> UIColor {
        var cString = hexString.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
        
        cString.dropPrefix("#")
        cString.dropPrefix("0X")
        
        let rString = (cString as NSString).substring(to:2)
        let gString = ((cString as NSString).substring(with: NSMakeRange(2, 2)))
        let bString = ((cString as NSString).substring(with: NSMakeRange(4, 2)))
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string:rString).scanHexInt32(&r)
        Scanner(string:gString).scanHexInt32(&g)
        Scanner(string:bString).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    
    public func toImage(size: CGSize = CGSize(width: 1.0, height: 1.0)) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(self.cgColor)
        context?.fill(rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result!
    }
    public func toCircularImage(size: CGSize = CGSize(width: 20, height: 20)) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: size.width/2)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(self.cgColor)
        path.fill()
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result!
    }
}
