//
//  TradeManger.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/12.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import PhotosUI
import Common
import RxSwift


class TradeManger {
    static let shared = TradeManger()
    
    private init() {
        
    }
    
    func searchTrades(tradeType: Trade.TradeType, filter: FilterOption?, sortType: TradeFuntionSort?) -> [Trade] {
        var trades = [Trade]()
        var result = RealmManager.share.realm.objects(Trade.self).filter(NSPredicate(format: "typeString == %@ AND eventName != ''", tradeType.rawValue))
        if let filter = filter {
            if filter.events.count > 0 {
                result = result.filter("eventName IN %@", filter.events.map { $0.name })
            }
            if filter.relations.count > 0 {
                result = result.filter("relationship IN %@", filter.relations.map { $0.name })
            }
            if let startTime = filter.startTime {
                result = result.filter("eventTime >= %@", startTime)
            }
            if let endTime = filter.endTime {
                result = result.filter("eventTime < %@", endTime)
            }
        }
        
        let sort = sortType ?? TradeFuntionSort.timeDescending
        switch sort {
        case .timeDescending:
            trades = result.sorted(byKeyPath: "eventTime", ascending: false).map{ $0 }
        case .timeAscending:
            trades = result.sorted(byKeyPath: "eventTime", ascending: true).map{ $0 }
        case .amountAscending:
            trades = result.sorted(by: { (t1, t2) -> Bool in
                return t1.totalMoney < t2.totalMoney
            })
        case .amountDescending:
            trades = result.sorted(by: { (t1, t2) -> Bool in
                return t1.totalMoney > t2.totalMoney
            })
        }
        return trades
    }
    
    func eventsGroup(trades: [Trade]) -> Dictionary<Event, (Event, [Trade])> {
        var tradeGroups = Dictionary<Event, (Event, [Trade])>()
        trades.forEach { (trade) in
            let groupKey = Event(name: trade.eventName, time: trade.eventTime, lastUseTime: trade.updateTime)
            if let oldValue = tradeGroups[groupKey] {
                oldValue.0.giftCount += trade.giftCount
                oldValue.0.totalMoney += trade.totalMoney
                oldValue.0.tradeCount += 1
                tradeGroups[groupKey]?.0 = oldValue.0
                tradeGroups[groupKey]?.1.append(trade)
            } else {
                groupKey.tradeCount = 1
                groupKey.giftCount = trade.giftCount
                groupKey.totalMoney = trade.totalMoney
                tradeGroups[groupKey] = (groupKey, [trade])
            }
        }
        return tradeGroups
    }
    
    func saveTrade(trade: Trade, oldTrade: Trade?, hasBackuped: Bool = false) -> Completable {
        RealmManager.share.realm.beginWrite()
        if let oldTrade = oldTrade {
            trade.id = oldTrade.id
            RealmManager.share.realm.delete(oldTrade.tradeItems)
        }
        trade.hasBackupToCloud = hasBackuped
        if !hasBackuped {
            trade.updateTime = Date()
        }
        RealmManager.share.realm.add(trade, update: .all)
        do {
            try RealmManager.share.realm.commitWrite()
        } catch let error {
            return Completable.error(error)
        }
        if !hasBackuped, AccountManager.shared.autoSyncToiCloudEnable {
            _ = CloudBackupQueue.shared.backupTradeInQueue(tradeID: trade.id)
        }
        OptionalService.shared.onTradeAdd(trade: trade)
        return Completable.empty()
        
    }
    
    func deleteTradeMedia(trade: Trade, tradeMedia: TradeMedia) -> Observable<Trade> {
        return Observable<Trade>.create { (observable) -> Disposable in
            do {
                try? FileManager.default.removeItem(at: tradeMedia.url)
                
                RealmManager.share.realm.beginWrite()
                if let index = trade.tradeMedias.index(of: tradeMedia) {
                    trade.tradeMedias.remove(at: index)
                }
                RealmManager.share.realm.add(trade, update: .modified)
                RealmManager.share.realm.delete(tradeMedia)
                try RealmManager.share.realm.commitWrite()
                observable.onNext(trade)
                observable.onCompleted()
            } catch let error {
                observable.onError(error)
            }
            return Disposables.create { }
        }
    }
    
    func deleteTrades(trades: [Trade]) -> Completable {
        return Observable<Trade>.from(trades).flatMap { (trade) -> Observable<String> in
            return self.deleteTrade(tradeID: trade.id)
        }.ignoreElements()
    }
    func deleteTrade(tradeID: String) -> Observable<String> {
        var mediaIDs = [String]()
        return Observable<String>.create { (observable) -> Disposable in
            DispatchQueue.global().async {
                do {
                    guard let trade = RealmManager.share.realm.object(ofType: Trade.self, forPrimaryKey: tradeID) else {
                        observable.onNext(tradeID)
                        observable.onCompleted()
                        return
                    }
                    for tradeMedia in trade.tradeMedias {
                        mediaIDs.append(tradeMedia.id)
                        try? FileManager.default.removeItem(at: tradeMedia.url)
                    }
                    RealmManager.share.realm.beginWrite()
                    RealmManager.share.realm.delete(trade.tradeMedias)
                    RealmManager.share.realm.delete(trade.tradeItems)
                    RealmManager.share.realm.delete(trade)
                    try RealmManager.share.realm.commitWrite()
                    observable.onNext(tradeID)
                    observable.onCompleted()
                } catch let error {
                    observable.onError(error)
                }
            }
            return Disposables.create { }
        }.do(onNext: { (tradeID) in
            if AccountManager.shared.autoSyncToiCloudEnable {
                _ = CloudManager.shared.deleteTradeAndMedias(tradeID: tradeID, mediaIDs: mediaIDs).subscribe()
            }
        }).observeOn(MainScheduler.instance)
    }
    
    func saveTradeMedias(trade: Trade?, newMedias: [TradeMedia]) -> Observable<Trade> {
        return Observable<Trade>.create { (observable) -> Disposable in
            RealmManager.share.realm.beginWrite()
            let newTrade = trade ?? Trade()
            newMedias.forEach({ (media) in
                media.tradeID = newTrade.id
            })
            newTrade.tradeMedias.append(objectsIn: newMedias)
            RealmManager.share.realm.add(newTrade, update: .all)
            
            var dispose: Disposable?
            do {
                try RealmManager.share.realm.commitWrite()
                dispose = Observable<TradeMedia>.from(newMedias)
                    .flatMap { $0.prepareForOriginUrl().concat($0.saveResourceIntoApp()) }
                    .ignoreElements()
                    .subscribe(onCompleted: {
                        observable.onNext(newTrade)
                        observable.onCompleted()
                    }) { (error) in
                        observable.onError(error)
                    }
            } catch let error {
                observable.onError(error)
            }
            return Disposables.create {
                dispose?.dispose()
            }
        }
    }
    
    func searchTrade(keyword: String) -> [Trade] {
        let predicate = NSPredicate(format: "name CONTAINS %@ OR relationship CONTAINS %@ OR eventName CONTAINS %@ OR remark CONTAINS %@", keyword, keyword, keyword, keyword)
        return RealmManager.share.realm.objects(Trade.self).filter(predicate).filter { $0.type != nil }
    }
}
