//
//  UIFont+appTheme.swift
//  GiftMoney
//
//  Created by binea on 2019/8/4.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    class func appFont(ofSize size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size)
    }
    
    class func appBoldFont(ofSize size: CGFloat) -> UIFont {
        return UIFont.boldSystemFont(ofSize: size)
    }
}
