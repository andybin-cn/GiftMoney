//
//  Trade.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/5.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import RealmSwift

class Trade: Object {
    enum TradeType: String {
        case inAccount = "inAccount"
        case outAccount = "outAccount"
    }
    
    @objc dynamic var id: String = NSUUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var relationship: String = ""
    @objc dynamic var eventName: String = ""
    @objc dynamic var eventTime: Date = Date()
    @objc dynamic private var typeString: String = ""
    
    var tradeItems = List<TradeItem>()
    var type: TradeType? {
        get {
            return TradeType.init(rawValue: typeString)
        }
        set {
            typeString = newValue?.rawValue ?? ""
        }
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class TradeItem: Object {
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
}

class TradeMedia: Object {
    enum MediaType: String {
        case image = "image"
        case video = "video"
    }
    
    @objc dynamic var id: String = NSUUID().uuidString
    @objc dynamic var tradeID: String = ""
    @objc dynamic private var typeString: String = ""
    @objc dynamic var path: String = ""
    
    var type: MediaType? {
        get {
            return MediaType.init(rawValue: typeString)
        }
        set {
            typeString = newValue?.rawValue ?? ""
        }
    }
}
