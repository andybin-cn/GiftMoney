//
//  ScreenHelp.swift
//  AnYou
//
//  Created by andy.bin on 2017/5/3.
//  Copyright © 2017年 binea. All rights reserved.
//

import Foundation
import UIKit

enum ScreenType {
    case size5_5
    case size4_7
    case size4_0
    case size3_5
}

class ScreenHelp {
    static var hairlineWidth: CGFloat {
        return 1/UIScreen.main.scale
    }
    
    static var screenType: ScreenType = { () in
        let size = UIScreen.main.bounds.size
        if size.height == 480 {
            return .size3_5
        } else if size.height == 568 {
            return .size4_0
        } else if size.height == 736 {
            return .size5_5
        } else {
            return .size4_7
        }
    }()
    
    static var statusBarHeight: CGFloat = { () in
        return UIApplication.shared.statusBarFrame.height
    }()
    
    static var tabBarHeight: CGFloat = { () in
        if #available(iOS 11.0, *) {
            return UIApplication.shared.windows[0].safeAreaInsets.bottom + 49
        } else {
            // Fallback on earlier versions
            return 49
        }
    }()
    
    static var safeAreaInsets: UIEdgeInsets = { () in
        if #available(iOS 11.0, *) {
            return UIApplication.shared.windows[0].safeAreaInsets
        } else {
            // Fallback on earlier versions
            return UIEdgeInsets(top: UIApplication.shared.statusBarFrame.height, left: 0, bottom: 0, right: 0)
        }
    }()
    
    static var navBarHeight: CGFloat = { () in
        return statusBarHeight + 44
    }()
    
}
