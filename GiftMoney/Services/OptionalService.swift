//
//  OptionalService.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/9/17.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import RxSwift

class OptionalService {
    static let shared = OptionalService()
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
        
        Event.systemEvents.forEach { (event) in
            if !latestusedEvents.contains(event) {
                allEvents.append(event)
            }
        }
        Relationship.systemRelationship.forEach { (relation) in
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
