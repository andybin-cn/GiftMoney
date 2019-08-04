//
//  Procedural.swift
//  AnYou
//
//  Created by Leo on 2017/3/4.
//  Copyright © 2017年 binea. All rights reserved.
//

import Foundation

public protocol Procedural: class {
    
}

extension Procedural {
    public typealias Processor = (Self) -> ()
    
    public static func process(_ processor: @escaping Processor ) -> Processor {
        return { i in
            processor(i)
        }
    }
    
    public func apply(_ processor: Processor) {
        processor(self)
    }
}

extension NSObject: Procedural {}
