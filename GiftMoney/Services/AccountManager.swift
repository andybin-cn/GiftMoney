//
//  AccountManager.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/28.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import CloudKit
import Common
import RxSwift

class AccountManager {
    static let shared = AccountManager()
    
    var userInfo: CKRecord?
    
    private init() {
        
    }
    
    func fetchUserInfo() -> Observable<CKRecord> {
        Observable<CKRecord>.create { (observer) -> Disposable in
            if let record = self.userInfo {
                observer.onNext(record)
                observer.onCompleted()
                return Disposables.create { }
            }
            let privateDB = CKContainer.default().privateCloudDatabase
            let id = CKRecord.ID.init(recordName: "UserInfo", zoneID: CKRecordZone.ID.init(zoneName: "UserInfo", ownerName: CKCurrentUserDefaultName))
            privateDB.fetch(withRecordID: id) { (record, error) in
                if let record = record {
                    self.userInfo = record
                    observer.onNext(record)
                    observer.onCompleted()
                } else if let error = error {
                    observer.onError(error)
                } else {
                    let record = self.initUserInfo(id: id)
                    self.userInfo = record
                    observer.onNext(record)
                    observer.onCompleted()
                }
            }
            return Disposables.create { }
        }
    }
    
    func initUserInfo(id: CKRecord.ID) -> CKRecord {
        let record = CKRecord(recordType: "UserInfo", recordID: id)
        record.setObject(false as __CKRecordObjCValue, forKey: "hasUsedInvitedCode")
        record.setObject("" as __CKRecordObjCValue, forKey: "usedInvitedCode")
        record.setObject("" as __CKRecordObjCValue, forKey: "InviteCode")
        CKContainer.default().privateCloudDatabase.save(record) { (_, _) in  }
        return record
    }
    
    func saveUserInfo() -> Observable<CKRecord> {
        guard let record = userInfo else {
            return Observable<CKRecord>.empty()
        }
        return Observable<CKRecord>.create { (observer) -> Disposable in
            CKContainer.default().privateCloudDatabase.save(record) { (_, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(record)
                    observer.onCompleted()
                }
            }
            return Disposables.create { }
        }
        
    }
    
}
