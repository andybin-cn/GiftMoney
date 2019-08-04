//
//  UIEdgeInsets+Extensions.swift
//  Common
//
//  Created by binea on 2018/9/22.
//  Copyright © 2018年 binea. All rights reserved.
//

import Foundation
import UIKit

public func -(l: UIEdgeInsets, r: UIEdgeInsets) -> UIEdgeInsets {
    return UIEdgeInsets(top: l.top - r.top, left: l.left - r.left, bottom: l.bottom - r.bottom, right: l.right - r.right)
}

public func +(l: UIEdgeInsets, r: UIEdgeInsets) -> UIEdgeInsets {
    return UIEdgeInsets(top: l.top + r.top, left: l.left + r.left, bottom: l.bottom + r.bottom, right: l.right + r.right)
}

public func -=( l: inout UIEdgeInsets, r: UIEdgeInsets) {
    l = l - r
}

public func +=( l: inout UIEdgeInsets, r: UIEdgeInsets) {
    l = l + r
}
