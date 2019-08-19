//
//  DispatchQueue.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/14.
//  Copyright © 2019 binea. All rights reserved.
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
