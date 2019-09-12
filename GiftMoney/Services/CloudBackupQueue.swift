//
//  CloudBackupQueue.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/9/12.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import RxSwift
import CloudKit

private enum UploadStatus {
    case waiting
    case uploading
    case finished
}

private class UploadItem {
    var tradeID: String
    var originObservable: Observable<CKRecord>
    var progressObservable: PublishSubject<CKRecord>
    var status: UploadStatus
    
    
    init(tradeID: String) {
        self.tradeID = tradeID
        status = .waiting
        originObservable = CloudManager.shared.backupTradeAndMedias(tradeID: tradeID)
        progressObservable = PublishSubject<CKRecord>()
    }
    
    func start() -> Observable<CKRecord> {
        status = .uploading
        _ = originObservable.subscribe(onNext: { (record) in
            self.progressObservable.onNext(record)
        }, onError: { (error) in
            self.status = .finished
            self.progressObservable.onError(error)
        }, onCompleted: {
            self.status = .finished
            self.progressObservable.onCompleted()
        })
        return progressObservable.asObserver()
    }
}

class CloudBackupQueue {
    static let shared = CloudBackupQueue()
    private init() { }
    
    private var items = [String: UploadItem]()
    
    func uploadItem(forTradeID tradeID: String) -> Observable<CKRecord>? {
        return items[tradeID]?.progressObservable.observeOn(MainScheduler.instance)
    }
    
    func backupTradeInQueue(tradeID: String) -> Observable<CKRecord> {
        if let item = items[tradeID] {
            return item.progressObservable.observeOn(MainScheduler.instance)
        }
        let item = UploadItem(tradeID: tradeID)
        items[tradeID] = item
        _ = item.progressObservable.asObserver().subscribe(onError: { (error) in
            self.onItemComplete(item: item)
        }, onCompleted: {
            self.onItemComplete(item: item)
        })
        if uploadingCount < 3 {
            return item.start()
        }
        return item.progressObservable.observeOn(MainScheduler.instance)
    }
    
    var uploadingCount: Int {
        return items.values.filter { $0.status == .uploading }.count
    }
    
    
    private func onItemComplete(item: UploadItem) {
        items.removeValue(forKey: item.tradeID)
        _ = items.first?.value.start()
    }
}
