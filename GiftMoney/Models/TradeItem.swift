//
//  TradeItem.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/8.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class TradeItem: Object, Mappable {
    enum ItemType: String {
        case money = "money"
        case gift = "gift"
    }
    
    @objc dynamic var id: String = NSUUID().uuidString
    @objc dynamic var tradeID: String = ""
    @objc dynamic private var typeString: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var value: String = ""
    
    var type: ItemType? {
        get {
            return ItemType.init(rawValue: typeString)
        }
        set {
            typeString = newValue?.rawValue ?? ""
        }
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapping(map: Map) {
        if map.mappingType == .fromJSON {
            id <- map["id"]
        } else {
            id >>> map["id"]
        }
        name <- map["name"]
        value <- map["value"]
        tradeID <- map["tradeID"]
        typeString <- map["type"]
    }
}
