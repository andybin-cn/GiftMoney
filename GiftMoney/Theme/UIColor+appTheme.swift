//
//  UIColor+appTheme.swift
//  GiftMoney
//
//  Created by binea on 2019/8/4.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import UIKit
import Common

extension UIColor {
    class var normalBackground: UIColor {
        UIColor.white
    }
    public static var appMainYellow: UIColor {
        return UIColor.from(hexString: "#FDBB0A")
    }
    public static var appMainBackground: UIColor {
        return UIColor.white
    }
    public static var appGrayBackground: UIColor {
        return UIColor.from(hexString: "#DFE0E0")
    }
    public static var appGrayLine: UIColor {
        return UIColor.lightGray
    }
    public static var appGrayText: UIColor {
        return UIColor.from(hexString: "#5a5a5a")
    }
    public static var appText: UIColor {
        return UIColor.darkText
    }
    public static var appTextBlue: UIColor {
        return UIColor.from(hexString: "#3b507f")
    }
    public static var appTextGreen: UIColor {
        return UIColor.from(hexString: "#009483")
    }
}
