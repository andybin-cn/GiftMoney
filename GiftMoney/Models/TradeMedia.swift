//
//  TradeMedia.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/8.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import UIKit

class TradeMedia: Object, Mappable {
    enum MediaType: String {
        case image = "image"
        case video = "video"
    }
    
    @objc dynamic var id: String = NSUUID().uuidString
    @objc dynamic var tradeID: String = ""
    @objc dynamic private var typeString: String = ""
    @objc dynamic var path: String = ""
    
    var originImage: UIImage?
    var originVidei: UIImage?
    
    var type: MediaType? {
        get {
            return MediaType.init(rawValue: typeString)
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
        id <- map["id"]
        tradeID <- map["tradeID"]
        typeString <- map["type"]
        path <- map["path"]
    }
}
