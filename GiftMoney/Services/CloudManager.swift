//
//  CloudManager.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/22.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import CloudKit
import RxSwift
import Common

struct CloudSyncProgress {
    let finishCount: Int
    let totoalCount: Int
}

typealias RecordsErrorHandler = ([CKRecord], Swift.Error?) -> Void

class CloudManager {
    static let shared = CloudManager()
    
    private init() {
        
    }
    
    func backupTrades() -> Observable<CloudSyncProgress> {
        return Observable<CloudSyncProgress>.create { (observable) -> Disposable in
            var disposable: Disposable?
            DispatchQueue.global().async {
                disposable = self.backupTradesInGlobalQueue(observable: observable)
            }
            return Disposables.create {
                disposable?.dispose()
            }
        }.observeOn(MainScheduler())
    }
    
    func backupTradesInGlobalQueue(observable: AnyObserver<CloudSyncProgress>) -> Disposable {
        let trades = RealmManager.share.realm.objects(Trade.self).filter(NSPredicate(format: "hasBackupToCloud == NO")).map { $0.id }
        let privateDB = CKContainer.default().privateCloudDatabase
        
        return Observable<String>.from(trades).flatMap { (tradeID) -> Observable<CKRecord> in
            return self.backupTrade(tradeID: tradeID, dataBase: privateDB)
        }.scan(CloudSyncProgress(finishCount: 0, totoalCount: trades.count)) { (progress, record) -> CloudSyncProgress in
            return CloudSyncProgress(finishCount: progress.finishCount + 1, totoalCount: progress.totoalCount)
        }.subscribe(onNext: { (progress) in
            observable.onNext(progress)
        }, onError: { (error) in
            observable.onError(error)
        }, onCompleted: {
            observable.onCompleted()
        })
    }
    
    func backupTrade(tradeID: String, dataBase: CKDatabase) -> Observable<CKRecord> {
        return Observable<CKRecord>.create { (observable) -> Disposable in
            let dispose = self.generatorRecordForTrade(tradeID: tradeID, dataBase: dataBase).subscribe(onNext: { (record) in
                DispatchQueue.global().async {
                    let (_, trade) = self.fillValues(target: record, from: tradeID)
                    let tradeName = trade?.name ?? tradeID
                    dataBase.save(record) { (record, error) in
                        if let record = record {
                            observable.onNext(record)
                            observable.onCompleted()
                        } else {
                            observable.onError(CommonError(message: "保存【\(tradeName)】失败。"))
                        }
                    }
                }
            }, onError: { (error) in
                observable.onError(error)
            })
            return Disposables.create {
                dispose.dispose()
            }
        }
    }
    
    
    func generatorRecordForTrade(tradeID: String, dataBase: CKDatabase) -> Observable<CKRecord> {
        return Observable<CKRecord>.create { (observable) -> Disposable in
            dataBase.fetch(withRecordID: CKRecord.ID(recordName: tradeID)) { (record, error) in
                if let error = error as? CKError {
                    if error.code == .unknownItem {
                        let record = CKRecord(recordType: "Trades", recordID: CKRecord.ID(recordName: tradeID))
                        observable.onNext(record)
                        observable.onCompleted()
                    } else {
                        observable.onError(error)
                    }
                } else if let record = record {
                    observable.onNext(record)
                    observable.onCompleted()
                } else {
                    observable.onError(CommonError.iCloudError)
                }
            }
            return Disposables.create { }
        }
    }
    
    func fillValues(target record: CKRecord, from tradeID: String) -> (CKRecord, Trade?) {
        guard let trade = RealmManager.share.realm.object(ofType: Trade.self, forPrimaryKey: tradeID) else {
            return (record, nil)
        }
        //是否需要这个判断，还是强制使用本地数据覆盖远程数据?
        if let updateTime = record.object(forKey: "updateTime") as? Date, updateTime > trade.updateTime {
            return (record, nil)
        }
        let tradeItems: [TradeItem] = trade.tradeItems.map { $0 }
        let tradeMedias: [TradeMedia] = trade.tradeMedias.map{ $0 }
        RealmManager.share.realm.beginWrite()
        let tradeItemsValue: String = tradeItems.toJSONString(prettyPrint: false) ?? ""
        let tradeMediasValue: String = tradeMedias.toJSONString(prettyPrint: false) ?? ""
        RealmManager.share.realm.cancelWrite()
        let assets = tradeMedias.map { (media) -> CKAsset in
            CKAsset(fileURL: media.url)
        }
        
        record.setObject(trade.id as __CKRecordObjCValue, forKey: "id")
        record.setObject((trade.type?.rawValue ?? "") as __CKRecordObjCValue, forKey: "typeString")
        record.setObject(trade.name as __CKRecordObjCValue, forKey: "name")
        record.setObject(trade.relationship as __CKRecordObjCValue, forKey: "relationship")
        record.setObject(trade.eventName as __CKRecordObjCValue, forKey: "eventName")
        record.setObject(trade.eventTime as __CKRecordObjCValue, forKey: "eventTime")
        record.setObject(trade.remark as __CKRecordObjCValue, forKey: "remark")
        record.setObject(trade.createTime as __CKRecordObjCValue, forKey: "createTime")
        record.setObject(trade.updateTime as __CKRecordObjCValue, forKey: "updateTime")
        record.setObject(tradeItemsValue as __CKRecordObjCValue, forKey: "tradeItems")
        record.setObject(tradeMediasValue as __CKRecordObjCValue, forKey: "tradeMedias")
        record.setObject(assets as __CKRecordObjCValue, forKey: "mediaAssets")
        
        return (record, trade)
    }
    
    func recoverTrades() -> Observable<CloudSyncProgress> {
        return fetchTradeRecords().flatMap({ self.saveRecordToDatabase(record: $0) }).scan(CloudSyncProgress(finishCount: 0, totoalCount: 0)) { (progress, sucess) -> CloudSyncProgress in
            if sucess {
                return CloudSyncProgress(finishCount: progress.finishCount + 1, totoalCount: progress.totoalCount + 1)
            }
            return CloudSyncProgress(finishCount: progress.finishCount, totoalCount: progress.totoalCount + 1)
        }.observeOn(MainScheduler())
    }
    
    private func fetchTradeRecords() -> Observable<CKRecord> {
        func createQueryOperation(observer: AnyObserver<CKRecord>, cursor: CKQueryOperation.Cursor?) -> CKQueryOperation {
            let queryOperation: CKQueryOperation
            if let cursor = cursor {
                queryOperation = CKQueryOperation(cursor: cursor)
            } else {
                let query = CKQuery(recordType: "Trades", predicate: NSPredicate(value: true))
                queryOperation = CKQueryOperation(query: query)
            }
            queryOperation.recordFetchedBlock = { record in
                observer.onNext(record)
            }
            
            queryOperation.queryCompletionBlock = { cursor, error in
                if let cursor = cursor {
                    let nextQueryOperation = createQueryOperation(observer: observer, cursor: cursor)
                    CKContainer.default().privateCloudDatabase.add(nextQueryOperation)
                } else if let error = error {
                    observer.onError(error)
                } else {
                    observer.onCompleted()
                }
            }
            
            return queryOperation
        }
        
        return Observable<CKRecord>.create { (observer) -> Disposable in
            let queryOperation = createQueryOperation(observer: observer, cursor: nil)
            CKContainer.default().privateCloudDatabase.add(queryOperation)
            return Disposables.create { }
        }
    }
    
    func saveRecordToDatabase(record: CKRecord) -> Observable<Bool> {
        guard let tradeID = record.object(forKey: "id") as? String else {
            return Observable<Bool>.from(optional: false)
        }
        guard let typeString = record.object(forKey: "typeString") as? String else {
            return Observable<Bool>.from(optional: false)
        }
        guard let name = record.object(forKey: "name") as? String else {
            return Observable<Bool>.from(optional: false)
        }
        guard let relationship = record.object(forKey: "relationship") as? String else {
            return Observable<Bool>.from(optional: false)
        }
        guard let eventName = record.object(forKey: "eventName") as? String else {
            return Observable<Bool>.from(optional: false)
        }
        guard let eventTime = record.object(forKey: "eventTime") as? Date else {
            return Observable<Bool>.from(optional: false)
        }
        guard let remark = record.object(forKey: "remark") as? String else {
            return Observable<Bool>.from(optional: false)
        }
        guard let createTime = record.object(forKey: "createTime") as? Date else {
            return Observable<Bool>.from(optional: false)
        }
        guard let updateTime = record.object(forKey: "updateTime") as? Date else {
            return Observable<Bool>.from(optional: false)
        }
        guard let tradeItemsString = record.object(forKey: "tradeItems") as? String else {
            return Observable<Bool>.from(optional: false)
        }
        guard let tradeMediasString = record.object(forKey: "tradeMedias") as? String else {
            return Observable<Bool>.from(optional: false)
        }
        guard let mediaAssets = record.object(forKey: "mediaAssets") as? [CKAsset] else {
            return Observable<Bool>.from(optional: false)
        }
        
        
        let oldTrade = RealmManager.share.realm.object(ofType: Trade.self, forPrimaryKey: tradeID)
        let newTrade = Trade()
        if let trade = oldTrade, trade.updateTime >= updateTime {
            return Observable<Bool>.from(optional: false)
        }
        newTrade.id = tradeID
        newTrade.type = Trade.TradeType(rawValue: typeString) ?? .outAccount
        newTrade.name = name
        newTrade.relationship = relationship
        newTrade.eventName = eventName
        newTrade.eventTime = eventTime
        newTrade.remark = remark
        newTrade.eventTime = eventTime
        newTrade.createTime = createTime
        newTrade.updateTime = updateTime
        
        let tradeItems = [TradeItem].init(JSONString: tradeItemsString) ?? [TradeItem]()
        let tradeMedias = [TradeMedia].init(JSONString: tradeMediasString) ?? [TradeMedia]()
        
        newTrade.tradeItems.append(objectsIn: tradeItems)
        newTrade.tradeMedias.append(objectsIn: tradeMedias)
        let result = TradeManger.shared.saveTrade(trade: newTrade, oldTrade: oldTrade)
        
        return Observable<Bool>.create { (observer) -> Disposable in
            _ = result.subscribe(onCompleted: {
                observer.onNext(true)
                observer.onCompleted()
            }) { (error) in
                observer.onNext(false)
                observer.onCompleted()
            }
            return Disposables.create { }
        }.do(onNext: { (success) in
            if success {
                ImagesManager.shared.recoverImages(assets: mediaAssets, medias: tradeMedias)
            }
        })
    }
}
