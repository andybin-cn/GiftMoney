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
    
    func eventsGroup() -> Dictionary<Event, [Trade]> {
        var tradeGroups = Dictionary<Event, [Trade]>()
        let trades = RealmManager.share.realm.objects(Trade.self).filter(NSPredicate(format: "typeString == %@ AND eventName != ''", Trade.TradeType.inAccount.rawValue)).sorted(byKeyPath: "updateTime", ascending: false)
        trades.forEach { (trade) in
            let groupKey = Event(name: trade.eventName, time: trade.eventTime, lastUseTime: trade.updateTime)
            if tradeGroups[groupKey] != nil {
                tradeGroups[groupKey]?.append(trade)
            } else {
                tradeGroups[groupKey] = [trade]
            }
        }
        return tradeGroups
    }
    
    func saveTrade(trade: Trade, oldTrade: Trade?) -> Completable {
        RealmManager.share.realm.beginWrite()
        if let oldTrade = oldTrade {
            trade.id = oldTrade.id
            RealmManager.share.realm.delete(oldTrade.tradeItems)
        }
        trade.updateTime = Date()
        RealmManager.share.realm.add(trade, update: .all)
        do {
            try RealmManager.share.realm.commitWrite()
        } catch let error {
            return Completable.error(error)
        }
        return Completable.empty()
    }
    
    func deleteTradeMedias(trade: Trade, tradeMedia: TradeMedia) -> Observable<Trade> {
        return Observable<Trade>.create { (observable) -> Disposable in
            do {
                try FileManager.default.removeItem(at: tradeMedia.url)
                
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
    
    func saveTradeMedias(trade: Trade?, newMedias: [TradeMedia]) -> Observable<Trade> {
        return Observable<Trade>.create { (observable) -> Disposable in
            RealmManager.share.realm.beginWrite()
            let newTrade = trade ?? Trade()
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
