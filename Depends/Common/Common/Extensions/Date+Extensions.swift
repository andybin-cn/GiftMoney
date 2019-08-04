//
//  Date+Extensions.swift
//  Common
//
//  Created by binea on 2017/3/14.
//  Copyright © 2017年 binea. All rights reserved.
//

import Foundation

extension Date {
    
    public func toString(withFormat format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
}
