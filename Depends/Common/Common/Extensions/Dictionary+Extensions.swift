//
//  Dictionary+Extensions.swift
//  Common
//
//  Created by binea on 2018/12/10.
//  Copyright © 2018 binea. All rights reserved.
//

import Foundation

public extension Dictionary where Key: StringProtocol {
    public func transformKeyToLowcase() -> [String: Value] {
        var result = [String: Value]()
        for (offset: _, element: (key: key, value: value)) in self.enumerated() {
            result[key.lowercased()] = value
        }
        return result
    }
}
