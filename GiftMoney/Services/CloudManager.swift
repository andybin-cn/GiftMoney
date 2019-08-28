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
        }
    }
    
    func backupTradesInGlobalQueue(observable: AnyObserver<CloudSyncProgress>) -> Disposable {
        let trades = RealmManager.share.realm.objects(Trade.self).filter(NSPredicate(format: "hasBackupToCloud == NO")).map { $0 }
        let privateDB = CKContainer.default().privateCloudDatabase
        
        return Observable<Trade>.from(trades).flatMapFirst { (trade) -> Observable<CKRecord> in
            return self.backuoTrade(trade: trade, dataBase: privateDB)
        }.scan(CloudSyncProgress(finishCount: 0, totoalCount: trades.count)) { (progress, record) -> CloudSyncProgress in
            return CloudSyncProgress(finishCount: progress.finishCount + 1, totoalCount: progress.totoalCount)
        }.subscribe(onNext: { (progress) in
            DispatchQueue.main.async {
                observable.onNext(progress)
            }
        }, onError: { (error) in
            DispatchQueue.main.async {
                observable.onError(error)
            }
        }, onCompleted: {
            DispatchQueue.main.async {
                observable.onCompleted()
            }
        })
    }
    
    func backuoTrade(trade: Trade, dataBase: CKDatabase) -> Observable<CKRecord> {
        Observable<CKRecord>.create { (observable) -> Disposable in
            let dispose = self.generatorRecordForTrade(trade: trade, dataBase: dataBase).subscribe(onNext: { (record) in
                dataBase.save(record) { (record, error) in
                    if let error = error {
                        observable.onError(error)
                    } else if let record = record {
                        observable.onNext(self.fillValues(target: record, from: trade))
                        observable.onCompleted()
                    } else {
                        observable.onError(CommonError(message: "保存【\(trade.name)】失败。"))
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
    
    
    func generatorRecordForTrade(trade: Trade, dataBase: CKDatabase) -> Observable<CKRecord> {
        Observable<CKRecord>.create { (observable) -> Disposable in
            dataBase.fetch(withRecordID: CKRecord.ID(recordName: trade.id)) { (record, error) in
                if let error = error {
                    observable.onError(error)
                } else if let record = record {
                    observable.onNext(record)
                    observable.onCompleted()
                } else {
                    let record = CKRecord(recordType: "Trades", recordID: CKRecord.ID(recordName: trade.id))
                    observable.onNext(record)
                    observable.onCompleted()
                }
            }
            return Disposables.create { }
        }
    }
    
    func fillValues(target record: CKRecord, from trade: Trade) -> CKRecord {
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
        record.setObject(trade.eventTime as __CKRecordObjCValue, forKey: "eventTime")
        record.setObject(trade.createTime as __CKRecordObjCValue, forKey: "createTime")
        record.setObject(trade.updateTime as __CKRecordObjCValue, forKey: "updateTime")
        record.setObject(tradeItemsValue as __CKRecordObjCValue, forKey: "tradeItems")
        record.setObject(tradeMediasValue as __CKRecordObjCValue, forKey: "tradeMedias")
        record.setObject(assets as __CKRecordObjCValue, forKey: "mediaAssets")
        
        return record
    }
}
