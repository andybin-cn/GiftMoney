//
//  ConstraintMakerRelatable+Extensions.swift
//  AnYou
//
//  Created by Leo on 2017/5/3.
//  Copyright © 2017年 binea. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

extension ConstraintMakerRelatable {
    func autoAdaptEqual(_ number: ConstraintRelatableTarget) {
        self.equalTo(number.floatValue * UIScreen.main.bounds.size.width / 750)
    }
}

extension ConstraintMakerEditable {
    func autoAdaptOffset(_ number: ConstraintOffsetTarget) {
        self.offset(number.floatValue * UIScreen.main.bounds.size.width / 750)
    }
    
    func autoAdaptInset(_ number: ConstraintOffsetTarget) {
        self.inset(number.floatValue * UIScreen.main.bounds.size.width / 750)
    }
}

extension ConstraintRelatableTarget {
    var floatValue: CGFloat {
        let offset: CGFloat
        if let amount = self as? Float {
            offset = CGFloat(amount)
        } else if let amount = self as? Double {
            offset = CGFloat(amount)
        } else if let amount = self as? CGFloat {
            offset = CGFloat(amount)
        } else if let amount = self as? Int {
            offset = CGFloat(amount)
        } else if let amount = self as? UInt {
            offset = CGFloat(amount)
        } else {
            offset = 0.0
        }
        return offset
    }
}
    
extension ConstraintOffsetTarget {
    var floatValue: CGFloat {
        let offset: CGFloat
        if let amount = self as? Float {
            offset = CGFloat(amount)
        } else if let amount = self as? Double {
            offset = CGFloat(amount)
        } else if let amount = self as? CGFloat {
            offset = CGFloat(amount)
        } else if let amount = self as? Int {
            offset = CGFloat(amount)
        } else if let amount = self as? UInt {
            offset = CGFloat(amount)
        } else {
            offset = 0.0
        }
        return offset
    }
}
