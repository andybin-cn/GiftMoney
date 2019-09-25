//
//  String+Extentions.swift
//  AnYou
//
//  Created by andy.bin on 2017/3/4.
//  Copyright © 2017年 binea. All rights reserved.
//

import Foundation

extension String {
    public func dropPrefixed(_ prefix: String) -> String {
        if hasPrefix(prefix) {
            return String(self[prefix.endIndex...])
        }
        return self
    }
    
    public mutating func dropPrefix(_ prefix: String) {
        self = dropPrefixed(prefix)
    }
    
    public func toDate(withFormat format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
    
    public func toDate() -> Date? {
        let regex = try! NSRegularExpression(pattern: "[0-9]+", options:[])
        let matches = regex.matches(in: self, options: [], range: NSRange(self.startIndex...,in: self))
        var yStr = ""
        var mStr = ""
        var dStr = ""
        if matches.count < 2 {
            return nil
        }
        yStr = String(self[Range(matches[0].range, in: self)!])
        mStr = String(self[Range(matches[1].range, in: self)!])
        if matches.count < 3 {
            return "\(yStr)-\(mStr)".toDate(withFormat: "yyyy-MM")
        }
        dStr = String(self[Range(matches[2].range, in: self)!])
        return "\(yStr)-\(mStr)-\(dStr)".toDate(withFormat: "yyyy-MM-dd")
    }
    
    
    public var isEmptyString: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
