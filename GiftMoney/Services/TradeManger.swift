//
//  TradeManger.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/12.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation

struct TradeEventGroupKey: Hashable {
    var name: String
    var time: Date
}


class TradeManger {
    var tradeGroups = Dictionary<TradeEventGroupKey, [Trade]>()
    
    
    init() {
        
    }
}
