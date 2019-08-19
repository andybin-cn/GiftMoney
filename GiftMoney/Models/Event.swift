//
//  Event.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/8.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

struct Event: Hashable {
    var name: String = ""
    var time: Date?
    var lastUseTime: Date?
    
    init(name: String, time: Date? = nil, lastUseTime: Date? = nil) {
        self.name = name
        self.time = time
        self.lastUseTime = lastUseTime
    }
    
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.name == rhs.name && lhs.time?.toString(withFormat: "yyyy-MM-dd") == rhs.time?.toString(withFormat: "yyyy-MM-dd")
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(time?.toString(withFormat: "yyyy-MM-dd"))
    }
}

private let eventName = ["参加婚礼", "宝宝出生", "宝宝满月", "宝宝周岁", "老人办寿", "乔迁新居", "金榜题名", "新店开业", "小孩升学", "压岁钱", "参加葬礼", "探望病人", "其他"]

extension Event {
    static var systemEvents: [Event] = eventName.map { Event(name: $0) }
    
    static var latestusedEvents: [Event] {
        var tradeGroups = Dictionary<Event, [Trade]>()
        let trades = RealmManager.share.realm.objects(Trade.self).filter(NSPredicate(format: "typeString != '' AND eventName != ''")).sorted(byKeyPath: "updateTime", ascending: false)
        trades.forEach { (trade) in
            let groupKey = Event(name: trade.eventName, time: trade.eventTime, lastUseTime: trade.updateTime)
            if var tradeGroup = tradeGroups[groupKey] {
                tradeGroup.append(trade)
            } else {
                tradeGroups[groupKey] = [trade]
            }
        }
        
        return tradeGroups.keys.sorted { (a, b) -> Bool in
            guard let t1 = a.lastUseTime else {
                return false
            }
            guard let t2 = b.lastUseTime else {
                return true
            }
            return t1 > t2
        }
    }
}
