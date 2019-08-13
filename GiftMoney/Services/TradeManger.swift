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
    var lastUseTime: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(time.toString(withFormat: "yyyy-MM-dd"))
    }
    
    
}




class TradeManger {
    static let shared = TradeManger()
    var inTradeGroups = Dictionary<TradeEventGroupKey, [Trade]>()
    var outTradeGroups = Dictionary<TradeEventGroupKey, [Trade]>()
    var outTrades = [Trade]()
    
    private init() {
        let intTrades = RealmManager.share.realm.objects(Trade.self).filter { item in item.type == Trade.TradeType.inAccount }
        intTrades.forEach { (trade) in
            let groupKey = TradeEventGroupKey(name: trade.eventName, time: trade.eventTime, lastUseTime: trade.updateTime)
            if var tradeGroup = inTradeGroups[groupKey] {
                tradeGroup.append(trade)
            } else {
                inTradeGroups[groupKey] = [trade]
            }
        }
        outTrades = RealmManager.share.realm.objects(Trade.self).filter { item in item.type == Trade.TradeType.outAccount }
    }
}
