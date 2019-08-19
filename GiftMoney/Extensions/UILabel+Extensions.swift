//
//  UILabel+Extentions.swift
//  AnYou
//
//  Created by binea on 2017/3/20.
//  Copyright © 2017年 binea. All rights reserved.
//

import UIKit

public extension UILabel {
    convenience init(textColor: UIColor, fontSize: CGFloat, textAlignment: NSTextAlignment = .left, text: String? = "") {
        self.init(frame: CGRect())
        
        self.textColor = textColor
        self.font = UIFont.appFont(ofSize: fontSize)
        self.textAlignment = textAlignment
        
        self.text = text
    }
    
    convenience init(textColor: UIColor, font: UIFont, textAlignment: NSTextAlignment = .left, text: String? = nil) {
        self.init(frame: CGRect())
        
        self.textColor = textColor
        self.font = font
        self.textAlignment = textAlignment
        
        self.text = text
    }
}
