//
//  UIViewController+HUD.swift
//  AnYou
//
//  Created by binea on 2017/3/6.
//  Copyright © 2017年 binea. All rights reserved.
//

import UIKit
import MBProgressHUD

class ABMBProgressHUD: MBProgressHUD {
    override var areDefaultMotionEffectsEnabled: Bool {
        get {
            return false
        }
        set { }
    }
}

extension UIViewController {
    
    public func showLoadingIndicator(text: String? = nil, afterDelay: TimeInterval = -1) {
        MBProgressHUD.hide(for: view, animated: false)
        let hud = ABMBProgressHUD(frame: view.bounds)
        hud.areDefaultMotionEffectsEnabled = false
        hud.removeFromSuperViewOnHide = true
        view.addSubview(hud)
        hud.mode = .indeterminate
        hud.label.text = text
        hud.label.numberOfLines = 0
        hud.show(animated: true)
        if afterDelay > 0 {
            hud.hide(animated: true, afterDelay: afterDelay)
        }
    }
    
    public func hiddenLoadingIndicator() {
        MBProgressHUD.hide(for: view, animated: true)
    }
    
    public func showTipsView(text: String) {
        MBProgressHUD.hide(for: view, animated: false)
        let hud = ABMBProgressHUD(frame: view.bounds)
        hud.areDefaultMotionEffectsEnabled = false
        hud.removeFromSuperViewOnHide = true
        view.addSubview(hud)
        hud.mode = .text
        hud.label.text = text
        hud.label.numberOfLines = 0
        hud.show(animated: true)
        hud.hide(animated: true, afterDelay: 2)
    }
}
