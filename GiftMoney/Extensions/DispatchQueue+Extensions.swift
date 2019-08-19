//
//  DispatchQueue+Extensions.swift
//  AnYou
//
//  Created by binea on 2017/7/15.
//  Copyright © 2017年 binea. All rights reserved.
//

import Foundation

extension DispatchQueue {
    static func globAsync(asyc: @escaping @convention(block) () -> Swift.Void, thenInMain: @escaping @convention(block) () -> Swift.Void) {
        DispatchQueue.global().async {
            asyc()
            
            DispatchQueue.main.sync {
                thenInMain()
            }
        }
    }
}
