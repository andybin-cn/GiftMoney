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
        
        return Observable<String>.from(trades).flatMap { (tradeID) -> Observable<CKRecord> in
            return self.backupTradeAndMedias(tradeID: tradeID)
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
    
    func backupTradeAndMedias(tradeID: String) -> Observable<CKRecord> {
        let privateDB = CKContainer.default().privateCloudDatabase
        return self.backupTrade(tradeID: tradeID, dataBase: privateDB).flatMap({ (trade, medias) -> Observable<CKRecord> in
            return self.backupTradeMedias(medias: medias, dataBase: privateDB).flatMap({ (_) -> Observable<CKRecord> in
                if let trade = RealmManager.share.realm.object(ofType: Trade.self, forPrimaryKey: tradeID) {
                    try? RealmManager.share.realm.write {
                        trade.hasBackupToCloud = true
                    }
                }
                return Observable<CKRecord>.from(optional: trade)
            })
        })
    }
    
    func backupTrade(tradeID: String, dataBase: CKDatabase) -> Observable<(CKRecord, [CKRecord])> {
        return Observable<(CKRecord, [CKRecord])>.create { (observable) -> Disposable in
            let dispose = self.generatorRecordForTrade(tradeID: tradeID, dataBase: dataBase).subscribe(onNext: { (record) in
                DispatchQueue.global().async {
                    let (newRecord, trade, mediaRecords) = self.fillValues(target: record, from: tradeID)
                    if let newRecord = newRecord {
                        let tradeName = trade?.name ?? tradeID
                        dataBase.save(newRecord) { (record, error) in
                            if let record = record {
                                observable.onNext((record, mediaRecords))
                                observable.onCompleted()
                            } else {
                                observable.onError(CommonError(message: "保存【\(tradeName)】失败。"))
                            }
                        }
                    } else {
                        observable.onNext((record, mediaRecords))
                        observable.onCompleted()
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
    func backupTradeMedias(medias: [CKRecord], dataBase: CKDatabase) -> Observable<Int> {
        return Observable<CKRecord>.from(medias).flatMap({ (record) -> Observable<Bool> in
            return self.backupTradeMedia(media: record, dataBase: dataBase).map({ _ in true }).catchError({ _ in Observable<Bool>.from(optional: false) })
        }).scan(0, accumulator: { (result, sucess) -> Int in
            sucess ? result+1 : result
        })
    }
    func backupTradeMedia(media: CKRecord, dataBase: CKDatabase) -> Observable<CKRecord> {
        return Observable<CKRecord>.create({ (observer) -> Disposable in
            dataBase.save(media, completionHandler: { (record, error) in
                if let error = error as? CKError {
                    if error.code == .serverRecordChanged {
                        observer.onNext(media)
                        observer.onCompleted()
                    } else {
                        observer.onError(error)
                    }
                } else if let record = record {
                    observer.onNext(record)
                    observer.onCompleted()
                } else {
                    observer.onError(error ?? CommonError.iCloudError)
                }
            })
            return Disposables.create { }
        })
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
    
    func fillValues(target record: CKRecord, from tradeID: String) -> (CKRecord?, Trade?, [CKRecord]) {
        var mediaRecords = [CKRecord]()
        guard let trade = RealmManager.share.realm.object(ofType: Trade.self, forPrimaryKey: tradeID) else {
            return (nil, nil, mediaRecords)
        }
        //是否需要这个判断，还是强制使用本地数据覆盖远程数据?
        if let updateTime = record.object(forKey: "updateTime") as? Date, updateTime >= trade.updateTime {
            return (nil, nil, mediaRecords)
        }
        let tradeItems: [TradeItem] = trade.tradeItems.map { $0 }
        let tradeMedias: [TradeMedia] = trade.tradeMedias.map{ $0 }
        RealmManager.share.realm.beginWrite()
        let tradeItemsValue: String = tradeItems.toJSONString(prettyPrint: false) ?? ""
        let tradeMediasValue: String = tradeMedias.toJSONString(prettyPrint: false) ?? ""
        RealmManager.share.realm.cancelWrite()
        
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
        
        mediaRecords = tradeMedias.map { (media) -> CKRecord in
            let typeString = media.type?.rawValue ?? ""
            let record = CKRecord(recordType: "TradeMedias", recordID: CKRecord.ID(recordName: media.id))
            record.setObject(CKAsset(fileURL: media.url) as __CKRecordObjCValue, forKey: "asset")
            record.setObject(typeString as __CKRecordObjCValue, forKey: "typeString")
            record.setObject(tradeID as __CKRecordObjCValue, forKey: "tradeID")
            record.setObject(media.id as __CKRecordObjCValue, forKey: "mediaID")
            return record
        }
        
        return (record, trade, mediaRecords)
    }
    
    func recoverTrades() -> Observable<CloudSyncProgress> {
        return fetchTradeRecords().flatMap({
            return self.saveTradeRecordToDatabase(record: $0).flatMap({ (trade) -> Observable<Bool> in
                if let trade = trade {
                    return self.recoverTradeMedias(trade: trade)
                } else {
                    return Observable<Bool>.from(optional: false)
                }
            })
        }).scan(CloudSyncProgress(finishCount: 0, totoalCount: 0)) { (progress, sucess) -> CloudSyncProgress in
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
    
    func recoverTradeMedias(trade: Trade) -> Observable<Bool> {
        let medias: [TradeMedia] = trade.tradeMedias.map { $0 }
        return Observable<TradeMedia>.from(medias).flatMap { (meida) -> Observable<Bool> in
            self.recoverTradeMedia(meida: meida)
        }.reduce(true) { (result, sucess) -> Bool in
            return true
        }
    }
    
    func recoverTradeMedia(meida: TradeMedia) -> Observable<Bool> {
        if FileManager.default.fileExists(atPath: meida.url.path) {
            return Observable<Bool>.from(optional: true)
        }
        return fetchMedias(medidID: meida.id).flatMap({ (record) -> Observable<CKRecord> in
            return self.saveMediaRecordToDatabase(record: record)
        }).map({ _ in
            return true
        }).catchError({ _ in
            return Observable<Bool>.from(optional: true)
        })
    }
    
    func fetchMedias(medidID: String) -> Observable<CKRecord> {
        return Observable<CKRecord>.create({ (observer) -> Disposable in
            let id = CKRecord.ID(recordName: medidID)
            CKContainer.default().privateCloudDatabase.fetch(withRecordID: id, completionHandler: { (record, error) in
                if let record = record {
                    observer.onNext(record)
                    observer.onCompleted()
                } else {
                    observer.onError(error ?? CommonError.iCloudError)
                }
            })
            return Disposables.create { }
        })
    }
    
    func saveMediaRecordToDatabase(record: CKRecord) -> Observable<CKRecord> {
        guard let asset = record.object(forKey: "asset") as? CKAsset else {
            return Observable<CKRecord>.error(CommonError.iCloudError)
        }
        guard let typeString = record.object(forKey: "typeString") as? String,
            let type = TradeMedia.MediaType(rawValue: typeString) else {
            return Observable<CKRecord>.error(CommonError.iCloudError)
        }
        guard let tradeID = record.object(forKey: "tradeID") as? String else {
            return Observable<CKRecord>.error(CommonError.iCloudError)
        }
        let mediaID = record.recordID.recordName
        let tradeMedia = TradeMedia()
        tradeMedia.id = mediaID
        tradeMedia.type = type
        tradeMedia.tradeID = tradeID
        
        return Observable<CKRecord>.from(optional: record).flatMap({ (_) -> Observable<CKRecord> in
            ImagesManager.shared.recoverImage(asset: asset, media: tradeMedia).map({_ in record})
        })
    }
    
    func saveTradeRecordToDatabase(record: CKRecord) -> Observable<Trade?> {
        guard let tradeID = record.object(forKey: "id") as? String else {
            return Observable<Trade?>.from(optional: nil)
        }
        guard let typeString = record.object(forKey: "typeString") as? String else {
            return Observable<Trade?>.from(optional: nil)
        }
        guard let name = record.object(forKey: "name") as? String else {
            return Observable<Trade?>.from(optional: nil)
        }
        guard let relationship = record.object(forKey: "relationship") as? String else {
            return Observable<Trade?>.from(optional: nil)
        }
        guard let eventName = record.object(forKey: "eventName") as? String else {
            return Observable<Trade?>.from(optional: nil)
        }
        guard let eventTime = record.object(forKey: "eventTime") as? Date else {
            return Observable<Trade?>.from(optional: nil)
        }
        guard let remark = record.object(forKey: "remark") as? String else {
            return Observable<Trade?>.from(optional: nil)
        }
        guard let createTime = record.object(forKey: "createTime") as? Date else {
            return Observable<Trade?>.from(optional: nil)
        }
        guard let updateTime = record.object(forKey: "updateTime") as? Date else {
            return Observable<Trade?>.from(optional: nil)
        }
        guard let tradeItemsString = record.object(forKey: "tradeItems") as? String else {
            return Observable<Trade?>.from(optional: nil)
        }
        guard let tradeMediasString = record.object(forKey: "tradeMedias") as? String else {
            return Observable<Trade?>.from(optional: nil)
        }
        
        
        let oldTrade = RealmManager.share.realm.object(ofType: Trade.self, forPrimaryKey: tradeID)
        let newTrade = Trade()
        if let trade = oldTrade, trade.updateTime >= updateTime {
            return Observable<Trade?>.from(optional: nil)
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
        newTrade.hasBackupToCloud = true
        
        let tradeItems = [TradeItem].init(JSONString: tradeItemsString) ?? [TradeItem]()
        let tradeMedias = [TradeMedia].init(JSONString: tradeMediasString) ?? [TradeMedia]()
        
        newTrade.tradeItems.append(objectsIn: tradeItems)
        newTrade.tradeMedias.append(objectsIn: tradeMedias)
        let result = TradeManger.shared.saveTrade(trade: newTrade, oldTrade: oldTrade, hasBackuped: true)
        
        return Observable<Trade?>.create { (observer) -> Disposable in
            _ = result.subscribe(onCompleted: {
                observer.onNext(newTrade)
                observer.onCompleted()
            }) { (error) in
                observer.onNext(nil)
                observer.onCompleted()
            }
            return Disposables.create { }
        }
    }
}
