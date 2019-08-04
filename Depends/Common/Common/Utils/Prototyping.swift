//
//  Prototyping.swift
//  Common
//
//  Created by binea on 2017/3/20.
//  Copyright © 2017年 binea. All rights reserved.
//

import Foundation

public protocol Prototyping: class { init() }


extension Prototyping {
    public typealias PrototypeMaker = () -> Self
    
    public static func prototype(_ initialize: @escaping (_ p: Self) -> Void) -> PrototypeMaker {
        return {
            let proto = self.init()
            initialize(proto)
            return proto
        }
    }
}

extension NSObject: Prototyping {}



