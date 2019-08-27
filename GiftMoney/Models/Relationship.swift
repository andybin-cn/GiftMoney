//
//  Relationship.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/16.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation

struct Relationship: Hashable {
    var name: String = ""
    var time: Date?
    init(name: String, time: Date? = nil) {
        self.name = name
        self.time = time
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: Relationship, rhs: Relationship) -> Bool {
        return lhs.name == rhs.name
    }
}

private let relationName = ["朋友", "同学", "同事", "亲戚", "兄弟", "邻里", "闺蜜", "基友"]

extension Relationship {
    static var systemRelationship: [Relationship] = relationName.map { Relationship(name: $0) }
    
    static var latestusedRelationships: [Relationship] {
        var tradeGroups = Dictionary<Relationship, [Trade]>()
        let trades = RealmManager.share.realm.objects(Trade.self).filter(NSPredicate(format: "relationship != ''")).sorted(byKeyPath: "updateTime", ascending: false)
        trades.forEach { (trade) in
            let groupKey = Relationship(name: trade.relationship, time: trade.updateTime)
            if var tradeGroup = tradeGroups[groupKey] {
                tradeGroup.append(trade)
            } else {
                tradeGroups[groupKey] = [trade]
            }
        }
        
        let allRelations = tradeGroups.keys.sorted { (a, b) -> Bool in
            guard let t1 = a.time else {
                return false
            }
            guard let t2 = b.time else {
                return true
            }
            return t1 > t2
        }
        return allRelations
    }
}
