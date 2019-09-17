//
//  OptionalService.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/9/17.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import RxSwift

private let eventName = ["参加婚礼", "宝宝出生", "宝宝满月", "宝宝周岁", "老人办寿", "乔迁新居", "金榜题名", "新店开业", "小孩升学", "压岁钱", "参加葬礼", "探望病人", "其他"]
private let relationName = ["朋友", "同学", "同事", "亲戚", "兄弟", "邻里", "闺蜜", "基友"]


class OptionalService {
    static let shared = OptionalService()
    
    var systemEvents: [Event] = eventName.map { Event(name: $0, time: nil, lastUseTime: nil, compareWithTime: false) }
    var systemRelationship: [Relationship] = relationName.map { Relationship(name: $0) }
    var newEventsEmit = PublishSubject<[Event]>()
    var newRelationEmit = PublishSubject<[Relationship]>()
    
    private(set) var latestusedEvents: [Event] = [Event]()
    private(set) var latestusedRelationships: [Relationship] = [Relationship]()
    
    private(set) var allEvents: [Event] = [Event]()
    private(set) var allRelationships: [Relationship] = [Relationship]()
    
    func initOptionals() {
        latestusedEvents = Event.latestusedEvents
        latestusedRelationships = Relationship.latestusedRelationships
        
        allEvents.append(contentsOf: latestusedEvents)
        allRelationships.append(contentsOf: latestusedRelationships)
        
        systemEvents.forEach { (event) in
            if !latestusedEvents.contains(event) {
                allEvents.append(event)
            }
        }
        systemRelationship.forEach { (relation) in
            if !latestusedRelationships.contains(relation) {
                allRelationships.append(relation)
            }
        }
        newEventsEmit.onNext(allEvents)
        newRelationEmit.onNext(allRelationships)
    }
    
    func onTradeAdd(trade: Trade) {
        let newEvent = Event(name: trade.eventName, time: trade.eventTime, lastUseTime: trade.updateTime, compareWithTime: false)
        if !latestusedEvents.contains(newEvent) {
            latestusedEvents.append(newEvent)
        }
        if !allEvents.contains(newEvent) {
            allEvents.append(newEvent)
            newEventsEmit.onNext([newEvent])
        }
        
        let newRelation = Relationship(name: trade.relationship, time: trade.updateTime)
        if !latestusedRelationships.contains(newRelation) {
            latestusedRelationships.append(newRelation)
        }
        if !allRelationships.contains(newRelation) {
            allRelationships.append(newRelation)
            newRelationEmit.onNext([newRelation])
        }
    }
}
