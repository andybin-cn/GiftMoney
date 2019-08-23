//
//  AboutUsVC.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/23.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import UIKit

class AboutUsVC: BaseViewController {
    
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.apply { (scrollView) in
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.alwaysBounceVertical = true
            scrollView.addTo(self.view) { (make) in
                make.edges.equalToSuperview()
            }
            
            UIView().apply { (widthView) in
                widthView.addTo(scrollView) { (make) in
                    make.left.right.top.equalToSuperview()
                    make.height.equalTo(0)
                    make.width.equalTo(self.view)
                }
            }
        }
        
        stackView.apply { (stackView) in
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 10
            
            stackView.addTo(scrollView) { (make) in
                make.centerX.equalToSuperview()
                make.top.equalTo(40)
            }
        }
    }
    
}
