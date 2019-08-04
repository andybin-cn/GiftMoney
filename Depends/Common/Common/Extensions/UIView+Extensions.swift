//
//  UIView+Extensions.swift
//  AnYou
//
//  Created by Leo on 2017/3/4.
//  Copyright © 2017年 binea. All rights reserved.
//

import UIKit
import SnapKit

extension UIView {
    public func addSubview(_ view: UIView, layout: (ConstraintMaker) -> Void) {
        addSubview(view)
        view.snp.makeConstraints { (make) in
            layout(make)
        }
    }
    
    public func addTo(_ superView: UIView) {
        superView.addSubview(self)
    }
    
    public func addTo(_ superView: UIView, layout: (ConstraintMaker) -> Void) {
        superView.addSubview(self)
        
        self.snp.makeConstraints { (make) in
            layout(make)
        }
    }
}
