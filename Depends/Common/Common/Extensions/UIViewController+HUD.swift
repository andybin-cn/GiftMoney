//
//  UIViewController+HUD.swift
//  AnYou
//
//  Created by binea on 2017/3/6.
//  Copyright © 2017年 binea. All rights reserved.
//

import UIKit
import MBProgressHUD

extension UIViewController {
    
    public func showLoadingIndicator(text: String? = nil) {
        MBProgressHUD.hide(for: view, animated: false)
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .indeterminate
        hud.label.text = text
    }
    
    public func hiddenLoadingIndicator() {
        MBProgressHUD.hide(for: view, animated: true)
    }
    
    public func showTipsView(text: String) {
        MBProgressHUD.hide(for: view, animated: false)
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .text
        hud.label.text = text
        hud.hide(animated: true, afterDelay: 2)
    }
}
