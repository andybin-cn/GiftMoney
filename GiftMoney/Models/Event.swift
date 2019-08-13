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

struct Event {
    var name: String = ""
    var time: Date?
    init(name: String, time: Date? = nil) {
        self.name = name
        self.time = time
    }
}

private let eventName = ["参加婚礼", "宝宝出生", "宝宝满月", "宝宝周岁", "老人办寿", "乔迁新居", "金榜题名", "新店开业", "小孩升学", "压岁钱", "参加葬礼", "探望病人", "其他"]

extension Event {
    static var systemEvents: [Event] = eventName.map { Event(name: $0) }
    
    static var latestusedEvents: [Event] {
        var allEvents = TradeManger.shared.inTradeGroups.keys.map { Event(name: $0.name, time: $0.lastUseTime) }
            + TradeManger.shared.outTradeGroups.keys.map { Event(name: $0.name, time: $0.lastUseTime) }
        allEvents.sort { (a, b) -> Bool in
            guard let t1 = a.time, let t2 = b.time else {
                return false
            }
            return t1 > t2
        }
        return allEvents
    }
}
