//
//  Then.swift
//  AnYou
//
//  Created by Leo on 2017/3/4.
//  Copyright © 2017年 binea. All rights reserved.
//

import Foundation

public protocol Then: class {
}

extension Then {
    public func then(_ block: (_ s: Self) -> Void) -> Self {
        block(self)
        return self
    }
    public func setProperties(_ block: (_ s: Self) -> Void) {
        block(self)
    }
}

extension NSObject: Then {}
