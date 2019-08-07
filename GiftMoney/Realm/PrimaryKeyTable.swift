////
////  PrimaryKeyTable.swift
////  GradingTest
////
////  Created by andy.bin on 2017/3/28.
////  Copyright © 2017年 DoSoMi. All rights reserved.
////
//import Foundation
//import RealmSwift
//
//protocol PrimaryKeyEnabel: class {
//    var primary_id:Int {get set}
//
//    init()
//    static func initWithPrimaryKey() -> Self
//}
//
//extension PrimaryKeyEnabel {
//    static func initWithPrimaryKey() -> Self {
//        let object = self.init()
//        object.primary_id = PrimaryKeyTableManager.default.primaryKey(for: "\(self)")
//        return object
//    }
//}
//
//class PrimaryKeyTable: Object {
//    dynamic var key = ""
//    dynamic var number = 1
//
//    override class func primaryKey() -> String? {
//        return "key"
//    }
//}
//
//class PrimaryKeyTableManager {
//    static let `default` = PrimaryKeyTableManager()
//
//    func primaryKey(for name: String) -> Int {
//        if let keyRow = RealmManager.share.realm.objects(PrimaryKeyTable.self).filter("key = %@", name).first {
//            RealmManager.share.realm.beginWrite()
//            keyRow.number += 1
//            RealmManager.share.realm.add(keyRow, update: Realm.UpdatePolicy.all)
//            try? RealmManager.share.realm.commitWrite()
//            return keyRow.number
//        } else {
//            let keyRow = PrimaryKeyTable()
//            keyRow.key = name
//            RealmManager.share.realm.beginWrite()
//            RealmManager.share.realm.add(keyRow)
//            try? RealmManager.share.realm.commitWrite()
//            return keyRow.number
//        }
//    }
//}
