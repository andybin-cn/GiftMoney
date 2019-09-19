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
    var autoSyncToiCloudEnable: Bool {
        didSet {
           UserDefaults.standard.set(autoSyncToiCloudEnable, forKey: "autoSyncToiCloudEnable")
            if autoSyncToiCloudEnable {
                if AccountManager.shared.autoSyncToiCloudEnable {
                    _ = CloudManager.shared.recoverTrades().subscribe(onError: { (error) in
                        Log.error("recoverTrades error:\(error.localizedDescription)")
                    }, onCompleted: {
                        MainTabViewController.shared.inoutRecordsVC.currentVC?.viewWillAppear(false)
                    })
                }
            }
        }
    }
    
    private init() {
        autoSyncToiCloudEnable = UserDefaults.standard.bool(forKey: "autoSyncToiCloudEnable")
    }
    
    func fetchAndCreateUserInfoZone() -> Observable<CKRecordZone> {
        return Observable<CKRecordZone>.create { (observer) -> Disposable in
            let privateDB = CKContainer.default().privateCloudDatabase
            let zoneID = CKRecordZone.ID.init(zoneName: "UserInfo", ownerName: CKCurrentUserDefaultName)
            privateDB.fetch(withRecordZoneID: zoneID) { (zone, error) in
                if let zone = zone {
                    observer.onNext(zone)
                } else if let ckError = error as? CKError, ckError.code == .zoneNotFound {
                    privateDB.save(CKRecordZone(zoneID: zoneID)) { (zone, error) in
                        if let zone = zone {
                            observer.onNext(zone)
                        } else {
                            observer.onError(CommonError.iCloudError)
                        }
                    }
                } else {
                    observer.onError(CommonError.iCloudError)
                }
            }
            
            return Disposables.create { }
        }
    }
    func fetchInviteCode() -> Observable<String?> {
        return fetchUserInfo().map { (record) -> String? in
            record.object(forKey: "InviteCode") as? String
        }
    }
    
    func fetchUserInfo() -> Observable<CKRecord> {
        if let record = self.userInfo {
            return Observable<CKRecord>.from(optional: record)
        } else {
            return fetchAndCreateUserInfoZone().flatMap {
                self.fetchAndCreateUserInfoRecord(zone: $0)
            }
        }
    }
    
    func fetchAndCreateUserInfoRecord(zone: CKRecordZone) -> Observable<CKRecord> {
        return Observable<CKRecord>.create { (observer) -> Disposable in
            let privateDB = CKContainer.default().privateCloudDatabase
            let id = CKRecord.ID.init(recordName: "UserInfo", zoneID: zone.zoneID)
            privateDB.fetch(withRecordID: id) { (record, error) in
                if let error = error as? CKError {
                    if error.code == .unknownItem {
                        let record = self.initUserInfo(id: id)
                        self.userInfo = record
                        observer.onNext(record)
                        observer.onCompleted()
                    } else {
                        observer.onError(error)
                    }
                } else if let record = record {
                    self.userInfo = record
                    observer.onNext(record)
                    observer.onCompleted()
                } else {
                    observer.onError(CommonError.iCloudError)
                }
            }
            return Disposables.create { }
        }
    }
    
    func initUserInfo(id: CKRecord.ID) -> CKRecord {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? ""
        
        let record = CKRecord(recordType: "UserInfo", recordID: id)
        record.setObject(false as __CKRecordObjCValue, forKey: "hasUsedInvitedCode")
        record.setObject("" as __CKRecordObjCValue, forKey: "usedInvitedCode")
        record.setObject("" as __CKRecordObjCValue, forKey: "InviteCode")
        record.setObject(UIDevice.current.name as __CKRecordObjCValue, forKey: "UserName")
        record.setObject(UIDevice.current.model as __CKRecordObjCValue, forKey: "DeviceName")
        record.setObject(identifier as __CKRecordObjCValue, forKey: "DeviceVersion")
        record.setObject(deviceID as __CKRecordObjCValue, forKey: "DeviceID")
        
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
