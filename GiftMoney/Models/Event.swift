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
    
    dynamic var id: String = NSUUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var actorName: String = ""
    @objc dynamic var address: String = ""
    @objc dynamic var time: String = ""
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        actorName <- map["actorName"]
        address <- map["address"]
        time <- map["time"]
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
