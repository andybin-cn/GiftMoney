//
//  UIButton+EnlargeEdge.swift
//  Common
//
//  Created by binea on 2017/3/14.
//  Copyright © 2017年 binea. All rights reserved.
//

import UIKit

extension UIButton {
    private static var topNameKey: Int8 = 0
    private static var rightNameKey: Int8 = 0
    private static var bottomNameKey: Int8 = 0
    private static var leftNameKey: Int8 = 0
    
    public func setEnlargeEdge(size: Float) {
        objc_setAssociatedObject(self, &UIButton.topNameKey, NSNumber(value: size), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &UIButton.rightNameKey, NSNumber(value: size), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &UIButton.bottomNameKey, NSNumber(value: size), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &UIButton.leftNameKey, NSNumber(value: size), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
    
    public func setEnlargeEdge(top: Float, right: Float, bottom: Float, left: Float) {
        objc_setAssociatedObject(self, &UIButton.topNameKey, NSNumber(value: top), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &UIButton.rightNameKey, NSNumber(value: right), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &UIButton.bottomNameKey, NSNumber(value: bottom), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &UIButton.leftNameKey, NSNumber(value: left), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
    
    private func enlargedRect() -> CGRect? {
        guard let topEdge = objc_getAssociatedObject(self, &UIButton.topNameKey) as? NSNumber,
                let rightEdge = objc_getAssociatedObject(self, &UIButton.rightNameKey) as? NSNumber,
                let bottomEdge = objc_getAssociatedObject(self, &UIButton.bottomNameKey) as? NSNumber,
            let leftEdge = objc_getAssociatedObject(self, &UIButton.leftNameKey) as? NSNumber else {
                return nil
        }
        return CGRect(x: self.bounds.origin.x - CGFloat(leftEdge.floatValue),
                      y: self.bounds.origin.y - CGFloat(topEdge.floatValue),
                      width: self.bounds.size.width + CGFloat(leftEdge.floatValue + rightEdge.floatValue),
                      height: self.bounds.size.height + CGFloat(topEdge.floatValue + bottomEdge.floatValue))
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if let rect = self.enlargedRect() {
            return rect.contains(point) ? true : false
        }
        return super.point(inside: point, with: event)
    }
}
