//
//  InviteManager.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/28.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import CloudKit
import RxSwift
import RxCocoa
import Common

private let PublicUserName = "PublicUser"

class InviteManager {
    static let shared = InviteManager()
    
    private(set) var inviteCode: String? {
        didSet {
            UserDefaults.standard.set(inviteCode, forKey: "InviteManager_inviteCode")
        }
    }
    private(set) var invitedCount: Int {
        didSet {
            UserDefaults.standard.set(invitedCount, forKey: "InviteManager_invitedCount")
            invitedCountRelay.accept(invitedCount)
        }
    }
    
    var invitedCountRelay: BehaviorRelay<Int>
    
    private(set) var usedCode: String? {
        didSet {
            UserDefaults.standard.set(usedCode, forKey: "InviteManager_usedCode")
        }
    }
    var hasUsedCode: Bool {
        return !(usedCode?.isEmpty ?? true)
    }
    
    private init() {
        inviteCode = UserDefaults.standard.value(forKey: "InviteManager_inviteCode") as? String
        invitedCount = UserDefaults.standard.value(forKey: "InviteManager_invitedCount") as? Int ?? 0
        usedCode = UserDefaults.standard.value(forKey: "InviteManager_usedCode") as? String
        invitedCountRelay = BehaviorRelay<Int>(value: invitedCount)
    }
    
    func useInviteCode(code: String) -> Observable<String> {
        AccountManager.shared.fetchUserInfo().flatMap { (record) -> Observable<String> in
            let hasUsedInvitedCode = record.object(forKey: "hasUsedInvitedCode") as? Bool ?? false
            if hasUsedInvitedCode {
                return Observable<String>.error(CommonError(message: "已经使用过邀请码，无法再次使用"))
            } else {
                return self.inserInviteCodeToUsedTable(code: code).do(onNext: { (code) in
                    self.usedCode = code
                })
            }
        }
    }
    
    private func inserInviteCodeToUsedTable(code: String) -> Observable<String> {
        Observable<String>.create { (observable) -> Disposable in
            let publicDB = CKContainer.default().publicCloudDatabase
            let record = CKRecord(recordType: "UsersForInviteCode")
            record.setObject(code as __CKRecordObjCValue, forKey: "InviteCode")
            record.setObject("" as __CKRecordObjCValue, forKey: "UserName")
            record.setObject(NSDate() as __CKRecordObjCValue, forKey: "UseTime")
            record.setObject("" as __CKRecordObjCValue, forKey: "DeviceName")
            publicDB.save(record) { (record, error) in
                if let error = error {
                    observable.onError(error)
                } else {
                    observable.onNext(code)
                    observable.onCompleted()
                }
            }
            return Disposables.create { }
        }
    }
    
    func fetchAndGeneratorInviteCode() -> Observable<(String, Int)> {
        let query = fetchInviteCode()
        let generator = saveInviteCodeToPublicDB().flatMapFirst { (code, _) -> Observable<(String, Int)> in
            return self.saveInviteCodeToPrivateDB(code: code)
        }
        return query.catchError { (error) -> Observable<(String, Int)> in
            if let error = error as? CommonError, error.code == -1 {
                return generator
            } else {
                return Observable<(String, Int)>.error(error)
            }
            }.do(onNext: { (code, count) in
                self.inviteCode = code
                self.invitedCount = count
            })
    }
    
    private func fetchInviteCode() -> Observable<(String, Int)> {
        return Observable<(String, Int)>.create { (observable) -> Disposable in
            let privateDB = CKContainer.default().privateCloudDatabase
            let publicDB = CKContainer.default().publicCloudDatabase
            let id = CKRecord.ID.init(recordName: "UserInfo", zoneID: CKRecordZone.ID.init(zoneName: "UserInfo", ownerName: CKCurrentUserDefaultName))
            privateDB.fetch(withRecordID: id) { (record, error) in
                if let error = error {
                    observable.onError(error)
                } else if let userInfo = record, let code = userInfo.value(forKey: "InviteCode") as? String {
                    let query = CKQuery(recordType: "UsersForInviteCode", predicate: NSPredicate(format: "InviteCode == %@", code))
                    publicDB.perform(query, inZoneWith: nil) { (records, error) in
                        if let error = error {
                            observable.onError(error)
                        } else if let records = records {
                            observable.onNext((code, records.count))
                        } else {
                            observable.onError(CommonError(message: "未知错误"))
                        }
                    }
                } else {
                    observable.onError(CommonError(message: "还没有创建记录", code: 1))
                }
            }
            return Disposables.create { }
        }
    }
    
    private func saveInviteCodeToPublicDB() -> Observable<(String, Int)> {
        return Observable<(String, Int)>.create { (observable) -> Disposable in
            let code = self.generatorRandomString()
            let publicDB = CKContainer.default().publicCloudDatabase
            let id = CKRecord.ID(recordName: code, zoneID: CKRecordZone.ID(zoneName: "InviteCode", ownerName: PublicUserName))
            let record = CKRecord(recordType: "InviteCode", recordID: id)
            record.setObject(0 as __CKRecordObjCValue, forKey: "InviteCount")
            publicDB.save(record) { (recoder, error) in
                if let error = error {
                    observable.onError(error)
                } else {
                    observable.onNext((code, 0))
                    observable.onCompleted()
                }
            }
            return Disposables.create {
                publicDB.delete(withRecordID: CKRecord.ID(recordName: code)) { (recoder, error) in
                    
                }
            }
        }
    }
    
    private func saveInviteCodeToPrivateDB(code: String) -> Observable<(String, Int)> {
        return AccountManager.shared.fetchUserInfo().flatMap { (record) -> Observable<(String, Int)> in
            record.setObject(code as __CKRecordObjCValue, forKey: "InviteCode")
            return AccountManager.shared.saveUserInfo().flatMap { (record) -> Observable<(String, Int)> in
                Observable<(String, Int)>.from([(code, 0)])
            }
        }
    }
    
    private func generatorRandomString() -> String {
        let codes = "23456789ABCDEFGHJKMNPQRSTUVWXYZ"
        var code = ""
        while code.count < 6 {
            let index = Int(arc4random()) % (codes.count - 1) + 0
            let startIndex = codes.index(codes.startIndex, offsetBy: index)
            let endIndex = codes.index(codes.startIndex, offsetBy: index + 1)
            code += String(codes[startIndex..<endIndex])
        }
        return code
    }
}
