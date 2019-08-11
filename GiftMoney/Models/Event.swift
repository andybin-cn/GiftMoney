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

class Event: Object, Mappable {
    enum EventType: String {
        case builtIn
        case recentlyUsed
        case associated
    }
    
    
    dynamic var id: String = NSUUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var actorName: String = ""
    @objc dynamic private var typeString: String = ""
    @objc dynamic var address: String = ""
    @objc dynamic var time: String = ""
    
    var type: EventType {
        get { EventType.init(rawValue: typeString) ?? .recentlyUsed }
        set { typeString = newValue.rawValue }
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        actorName <- map["actorName"]
        address <- map["address"]
        time <- map["time"]
        typeString <- map["typeString"]
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
