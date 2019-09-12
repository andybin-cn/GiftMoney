//
//  UIView+Extensions.swift
//  AnYou
//
//  Created by andy.bin on 2017/3/4.
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
    
    public var firstViewController: UIViewController? {
        var target: UIResponder = self
        while let next = target.next {
            target = next
            if let controller = next as? UIViewController {
                return controller
            }
        }
        return nil
    }
}
