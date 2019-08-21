//
//  Trade.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/5.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class Trade: Object, Mappable {
    enum TradeType: String {
        case inAccount = "inAccount"
        case outAccount = "outAccount"
    }
    
    @objc dynamic var id: String = NSUUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var relationship: String = ""
    @objc dynamic var remark: String = ""
    @objc dynamic var eventName: String = ""
    @objc dynamic var eventTime: Date = Date()
    @objc dynamic var updateTime: Date = Date()
    @objc dynamic var createTime: Date = Date()
    @objc dynamic private var typeString: String = ""
    
    private var _tradeItems: Array<TradeItem> = Array<TradeItem>() {
        didSet {
            tradeItems.removeAll()
            tradeItems.append(objectsIn: _tradeItems)
        }
    }
    private var _tradeMedias: Array<TradeMedia> = Array<TradeMedia>() {
        didSet {
            tradeMedias.removeAll()
            tradeMedias.append(objectsIn: _tradeMedias)
        }
    }
    
    var tradeItems = List<TradeItem>()
    var tradeMedias = List<TradeMedia>()
    
    var type: TradeType? {
        get {
            return TradeType.init(rawValue: typeString)
        }
        set {
            typeString = newValue?.rawValue ?? ""
        }
    }
    
    var giftCount: Int {
        return tradeItems.filter{ $0.type == TradeItem.ItemType.gift }.count
    }
    var totalMoney: Float {
        return tradeItems.reduce(0.0) { (r, item) -> Float in
            guard item.type == .money, let money = Float(item.value) else {
                return r
            }
            return r + money
        }
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    override static func indexedProperties() -> [String] {
        return ["id", "name", "relationship", "remark"]
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        relationship <- map["relationship"]
        remark <- map["remark"]
        eventName <- map["eventName"]
        eventTime <- map["eventTime"]
        typeString <- map["type"]
        _tradeItems <- map["tradeItems"]
        _tradeMedias <- map["tradeMedias"]
    }
}

