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
            let usedInvitedCode = record.object(forKey: "usedInvitedCode") as? String ?? ""
            if hasUsedInvitedCode, !usedInvitedCode.isEmpty {
                self.usedCode = usedInvitedCode
                return Observable<String>.error(CommonError(message: "已经使用过邀请码，无法再次使用"))
            } else {
                return self.checkInviteCode(code: code).flatMap { _ in
                    return self.inserInviteCodeToUsedTable(code: code).do(onNext: { (code) in
                        self.usedCode = code
                    }).flatMap { (_) -> Observable<String> in
                        record.setObject(true as __CKRecordObjCValue, forKey: "hasUsedInvitedCode")
                        record.setObject(code as __CKRecordObjCValue, forKey: "usedInvitedCode")
                        return AccountManager.shared.saveUserInfo().map { _ in code }
                    }
                }
            }
        }.observeOn(MainScheduler())
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
        
        let generatInviteCode = saveInviteCodeToPublicDB().retryWhen { (observer) -> Observable<Int> in
            observer.flatMap { (error) -> Observable<Int> in
                if let error = error as? CommonError, error.code == 2 {
                    return Observable<Int>.from(optional: 0)
                } else {
                    return Observable<Int>.error(error)
                }
            }
        }
        
        let generator = generatInviteCode.flatMapFirst { (code, _) -> Observable<(String, Int)> in
            return self.saveInviteCodeToPrivateDB(code: code)
        }
        
        return query.catchError { (error) -> Observable<(String, Int)> in
            if let error = error as? CommonError, error.code == 1 {
                return generator
            } else {
                return Observable<(String, Int)>.error(error)
            }
        }.do(onNext: { (code, count) in
            self.inviteCode = code
            self.invitedCount = count
        }).observeOn(MainScheduler.init())
    }
    
    private func fetchInviteCodeUseCount(inviteCode: String) -> Observable<Int> {
        return Observable<Int>.create { (observable) -> Disposable in
            let publicDB = CKContainer.default().publicCloudDatabase
            let query = CKQuery(recordType: "UsersForInviteCode", predicate: NSPredicate(format: "InviteCode == %@", inviteCode))
            publicDB.perform(query, inZoneWith: nil) { (records, error) in
                if let error = error as? CKError {
                    if error.code == CKError.Code.unknownItem {
                        observable.onNext(0)
                        observable.onCompleted()
                    } else {
                        observable.onError(CommonError.iCloudError)
                    }
                } else if let records = records {
                    observable.onNext(records.count)
                    observable.onCompleted()
                } else {
                    observable.onError(CommonError.iCloudError)
                }
            }
            return Disposables.create { }
        }
    }
    
    private func fetchInviteCode() -> Observable<(String, Int)> {
        return AccountManager.shared.fetchInviteCode().flatMap { (code) -> Observable<(String, Int)> in
            if let code = code, !code.isEmpty {
                return self.fetchInviteCodeUseCount(inviteCode: code).map { (code, $0) }
            } else {
                return Observable<(String, Int)>.error(CommonError.init(message: "还没有创建记录", code: 1))
            }
        }
    }
    
    private func checkInviteCode(code: String) -> Observable<String> {
        return Observable<String>.create { (observer) -> Disposable in
            if code == self.inviteCode {
                observer.onError(CommonError(message: "不能使用自己的邀请码!"))
            } else {
                let id = CKRecord.ID(recordName: code)
                let publicDB = CKContainer.default().publicCloudDatabase
                publicDB.fetch(withRecordID: id) { (record, error) in
                    if record != nil {
                        observer.onNext(code)
                        observer.onCompleted()
                    } else {
                        observer.onError(CommonError(message: "邀请码不存在"))
                    }
                }
            }
            return Disposables.create { }
        }
    }
    
    private func saveInviteCodeToPublicDB() -> Observable<(String, Int)> {
        return Observable<(String, Int)>.create { (observable) -> Disposable in
            let code = self.generatorRandomString()
            let publicDB = CKContainer.default().publicCloudDatabase
            let id = CKRecord.ID(recordName: code)
            let record = CKRecord(recordType: "InviteCode", recordID: id)
            record.setObject(code as __CKRecordObjCValue, forKey: "InviteCode")
            record.setObject(0 as __CKRecordObjCValue, forKey: "InviteCount")
            publicDB.save(record) { (recoder, error) in
                if let ckError = error as? CKError {
                    print("ckError:\(ckError)")
                    if ckError.code == CKError.Code.serverRecordChanged {
                        observable.onError(CommonError(message: "邀请码已存在", code: 2))
                    } else {
                        observable.onError(ckError)
                    }
                } else {
                    observable.onNext((code, 0))
                    observable.onCompleted()
                }
            }
            return Disposables.create { }
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
