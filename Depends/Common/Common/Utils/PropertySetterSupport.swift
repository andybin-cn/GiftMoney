//
//  PropertySetterSupport.swift
//  AnYou
//
//  Created by Leo on 2017/3/4.
//  Copyright © 2017年 binea. All rights reserved.
//

import Foundation

public protocol PropertySetterSupport {
    
}

extension PropertySetterSupport {
    
    public typealias PropertySetter = (Self) -> Void
    
    public static func propertySetter(setter:@escaping ((Self) -> Void)) -> PropertySetter {
    let process: PropertySetter = { (object) in
            setter(object)
        }
        return process
    }

}

//extension NSObject: Prototyping {}
extension NSObject: PropertySetterSupport {}
