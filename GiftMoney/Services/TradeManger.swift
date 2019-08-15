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

struct TradeEventGroupKey: Hashable {
    var name: String
    var time: Date
    var lastUseTime: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(time.toString(withFormat: "yyyy-MM-dd"))
    }
    
    
}




class TradeManger {
    static let shared = TradeManger()
    var inTradeGroups = Dictionary<TradeEventGroupKey, [Trade]>()
    var outTradeGroups = Dictionary<TradeEventGroupKey, [Trade]>()
    var outTrades = [Trade]()
    
    private init() {
//        let intTrades = RealmManager.share.realm.objects(Trade.self).filter { item in item.type == Trade.TradeType.inAccount }
//        intTrades.forEach { (trade) in
//            let groupKey = TradeEventGroupKey(name: trade.eventName, time: trade.eventTime, lastUseTime: trade.updateTime)
//            if var tradeGroup = inTradeGroups[groupKey] {
//                tradeGroup.append(trade)
//            } else {
//                inTradeGroups[groupKey] = [trade]
//            }
//        }
//        outTrades = RealmManager.share.realm.objects(Trade.self).filter { item in item.type == Trade.TradeType.outAccount }
    }
    
    func saveTrade(trade: Trade, oldTrade: Trade?) -> Completable {
        RealmManager.share.realm.beginWrite()
        if let oldTrade = oldTrade {
            trade.id = oldTrade.id
            RealmManager.share.realm.delete(oldTrade.tradeItems)
            let deletedMedias = oldTrade.tradeMedias.filter{ (oldMedia) -> Bool in
                return !trade.tradeMedias.contains { (newMedia) -> Bool in
                    return oldMedia.id == newMedia.id
                }
            }
            RealmManager.share.realm.delete(deletedMedias)
        }
        let medias: [TradeMedia] = trade.tradeMedias.filter { !$0.hasSaved }
//        medias.forEach { (media) in
//            let suffix = media.type == .image ? ".png" : ".mov"
//            media.path = URL(string: NSHomeDirectory() + "/Documents/\(NSUUID().uuidString)\(suffix)")?.path ?? ""
//        }
        RealmManager.share.realm.add(trade, update: .all)
        do {
            try RealmManager.share.realm.commitWrite()
        } catch let error {
            return Completable.error(error)
        }
        return Observable<TradeMedia>.from(medias).flatMap { (media) -> Observable<TradeMedia> in
            return media.saveResourceIntoApp()
        }.ignoreElements()
    }
}
