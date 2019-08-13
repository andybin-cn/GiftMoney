//
//  AllTradesVC.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/13.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import UIKit

class AllTradesVC: BaseViewController {
    let tabbar = UIView()
    let containerView = UIView()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        tabbar.apply { (tabbar) in
            tabbar.addTo(view) { (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(40)
                make.top.equalTo(ScreenHelp.navBarHeight)
            }
        }
        
        containerView.apply { (containerView) in
            containerView.addTo(view) { (make) in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(tabbar.snp.bottom)
            }
        }
        
        view.bringSubviewToFront(tabbar)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let inAccountButton = UIButton()
    let outAccountButton = UIButton()
    func settupTabbar() {
        
    }
    
}
