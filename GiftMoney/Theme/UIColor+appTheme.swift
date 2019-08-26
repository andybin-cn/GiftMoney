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
    public static var appMainRed: UIColor {
        return UIColor.from(hexString: "#E03636")
    }
    public static var appSecondaryRed: UIColor {
        return UIColor.from(hexString: "#FF534D")
    }
    public static var appSecondaryGray: UIColor {
        return UIColor.from(hexString: "#EDD0BE")
    }
    public static var appSecondaryYellow: UIColor {
        return UIColor.from(hexString: "#FFD948")
    }
    public static var appSecondaryBlue: UIColor {
        return UIColor.from(hexString: "#25C6FC")
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
