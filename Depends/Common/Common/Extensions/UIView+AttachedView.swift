//
//  UIView+AttachedView.swift
//  Common
//
//  Created by binea on 2017/3/16.
//  Copyright © 2017年 binea. All rights reserved.
//

import Foundation
import SnapKit
import UIKit
import ObjectiveC

public enum ViewAttachedPosition {
    case leftTop
    case leftCenter
    case leftBottom
    
    case rightTop
    case rightCenter
    case rightBottom
    
    case topLeft
    case topCenter
    case topRight
    
    case bottomLeft
    case bottomCenter
    case bottomRight
}

//Attached view 将在目标view周围进行附加

extension UIView {
    private class AttachedView: NSObject {
        static var attachedViewsKey = "attachedViews"
    }
    
    private var attchedViews: [ViewAttachedPosition : UIView] {
        get {
            var views = objc_getAssociatedObject(self, &AttachedView.attachedViewsKey) as? [ViewAttachedPosition : UIView]
            if views == nil {
                views = [ViewAttachedPosition : UIView]()
                objc_setAssociatedObject(self, &AttachedView.attachedViewsKey, views! as NSDictionary, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return views!
        }
        set {
            objc_setAssociatedObject(self, &AttachedView.attachedViewsKey, newValue as NSDictionary, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func addAttachedView(_ view: UIView, at position: ViewAttachedPosition, spacing: CGFloat = 0) {
        removeAttachedView(at: position)
        
        attchedViews[position] = view
        self.addSubview(view)
        
        switch position {
        case .leftTop:
            view.snp.makeConstraints({ (make) in
                make.right.equalTo(self.snp.left).offset(-spacing)
                make.top.equalToSuperview()
            })
        case .leftCenter:
            view.snp.makeConstraints({ (make) in
                make.right.equalTo(self.snp.left).offset(-spacing)
                make.centerY.equalToSuperview()
            })
        case .leftBottom:
            view.snp.makeConstraints({ (make) in
                make.right.equalTo(self.snp.left).offset(-spacing)
                make.bottom.equalToSuperview()
            })
        case .rightTop:
            view.snp.makeConstraints({ (make) in
                make.left.equalTo(self.snp.right).offset(spacing)
                make.top.equalToSuperview()
            })
        case .rightCenter:
            view.snp.makeConstraints({ (make) in
                make.left.equalTo(self.snp.right).offset(spacing)
                make.centerY.equalToSuperview()
            })
        case .rightBottom:
            view.snp.makeConstraints({ (make) in
                make.left.equalTo(self.snp.right).offset(spacing)
                make.bottom.equalToSuperview()
            })
        case .topLeft:
            view.snp.makeConstraints({ (make) in
                make.bottom.equalTo(self.snp.top).offset(-spacing)
                make.left.equalToSuperview()
            })
        case .topCenter:
            view.snp.makeConstraints({ (make) in
                make.bottom.equalTo(self.snp.top).offset(-spacing)
                make.centerY.equalToSuperview()
            })
        case .topRight:
            view.snp.makeConstraints({ (make) in
                make.bottom.equalTo(self.snp.top).offset(-spacing)
                make.right.equalToSuperview()
            })
        case .bottomLeft:
            view.snp.makeConstraints({ (make) in
                make.top.equalTo(self.snp.bottom).offset(spacing)
                make.left.equalToSuperview()
            })
        case .bottomCenter:
            view.snp.makeConstraints({ (make) in
                make.top.equalTo(self.snp.bottom).offset(spacing)
                make.centerX.equalToSuperview()
            })
        case .bottomRight:
            view.snp.makeConstraints({ (make) in
                make.top.equalTo(self.snp.bottom).offset(spacing)
                make.right.equalToSuperview()
            })
        }
    }
    
    public func removeAttachedView(at position: ViewAttachedPosition) {
        if let view = attchedViews[position] {
            view.snp.removeConstraints()
            view.removeFromSuperview()
            
            attchedViews[position] = nil
        }
    }
    
    public func attachedView(at position: ViewAttachedPosition) -> UIView? {
        return attchedViews[position]
    }
}
