//
//  Array+Extensions.swift
//  Common
//
//  Created by binea on 2018/12/9.
//  Copyright © 2018 binea. All rights reserved.
//

import Foundation

public extension Array {
    
    public func findFirst(predicate: (Element) -> Bool) -> Element? {
        var result: Element?
        self.forEach { (item) in
            if predicate(item) {
                result = item
                return
            }
        }
        return result
    }
}
