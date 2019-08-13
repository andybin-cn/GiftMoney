//
//  RealmManager.swift
//  GradingTest
//
//  Created by andy.bin on 2017/3/28.
//  Copyright © 2017年 DoSoMi. All rights reserved.
//

import RealmSwift
import Realm

class RealmManager {
    
    static let share = RealmManager()
    
    var realm: Realm {
        return try! Realm(fileURL: URL(string: NSHomeDirectory() + "/Documents/sharedRealm.realm")!)
    }
    
    init() {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 1,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
//                if (oldSchemaVersion == 1 ) {
//                    migration.enumerateObjects(ofType: ExamVideoInfo.className()) { oldObject, newObject in
//                        // combine name fields into a single field
//                        newObject!["remark"] = oldObject!["remarks"]
//                    }
//                }
        })
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
    
}

protocol ThreadSafeReferenceProtocal: ThreadConfined {
    
}

extension ThreadSafeReferenceProtocal {
    func resolve(to realm: Realm) -> Self? {
        let ref = ThreadSafeReference<Self>(to: self)
        return realm.resolve(ref)
    }
}

extension Object: ThreadSafeReferenceProtocal {
    /**
    func resolve<T: Object>(to realm: Realm) -> T? {
        let ref = ThreadSafeReference<T>(to: self as! T)
        return realm.resolve(ref)
    }
 **/
}
