//
//  MaketManager.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/20.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation

class MaketManager {
    enum Level: Int {
        case free
        case paid1
        case paid2
    }
    
    
    static let shared = MaketManager()
    
    private init() {
        
    }
    
    var currentLevel = Level.free
    
}
