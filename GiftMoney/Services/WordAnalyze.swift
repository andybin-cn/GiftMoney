//
//  WordAnalyze.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/9/16.
//  Copyright © 2019 binea. All rights reserved.
//

import UIKit
import Common

class AnalyzeResult {
    var name: String = ""
    var giftName: String = ""
    var value: String = ""
    var unit: String = ""
    var unitType: TradeItem.ItemType = .money
    var type: Trade.TradeType? = nil
    var error: Error? = nil
    var event: String = ""
    var relation: String = ""
}

enum AnalyzeTagType: String {
    case name
    case giftName
    case giftUnit
    case moneyUnit
    case value
    case giftValue
    case eventName
    case relationName
}

class AnalyzeTag {
    var word: String = ""
    var jieBaTag: String = ""
    var type: AnalyzeTagType?
    var confidence: Float = -1
    var index: Int = -1
    
    init(tag: JieBaTag) {
        word = tag.word
        jieBaTag = tag.tag
    }
    
    var string: String {
        let typeStr = type?.rawValue ?? " "
        return "\(word)-\(confidence)-\(typeStr)"
    }
    
}


class WordAnalyze {
    let analyzeTags: [AnalyzeTag]
    init(tags: Array<JieBaTag>) {
        analyzeTags = tags.map{ AnalyzeTag(tag: $0) }
    }
    
    func findMaxConfidenceFor(type: AnalyzeTagType) -> AnalyzeTag? {
        var resultTag: AnalyzeTag?
        for tag in analyzeTags {
            if tag.type == type {
                if resultTag == nil || resultTag!.confidence < tag.confidence {
                    resultTag = tag
                }
            }
        }
        return resultTag
    }
    
    var nameTag: AnalyzeTag? {
        return findMaxConfidenceFor(type: .name)
    }
    var valueTag: AnalyzeTag? {
        return findMaxConfidenceFor(type: .value)
    }
    var moneyUnitTag: AnalyzeTag? {
        return findMaxConfidenceFor(type: .moneyUnit)
    }
    var giftNameTag: AnalyzeTag? {
        return findMaxConfidenceFor(type: .giftName)
    }
    var giftUnitTag: AnalyzeTag? {
        return findMaxConfidenceFor(type: .giftUnit)
    }
    var relationTag: AnalyzeTag?
    {
        return findMaxConfidenceFor(type: .relationName)
    }
    var eventTag: AnalyzeTag?
    {
        return findMaxConfidenceFor(type: .eventName)
    }
    var unitType: TradeItem.ItemType? {
        if let giftTag = giftUnitTag {
            return giftTag.confidence > (moneyUnitTag?.confidence ?? 0) ? .gift : .money
        } else {
            return .money
        }
    }
    var type: Trade.TradeType?
    
    
    func analyzeSentence() -> AnalyzeResult {
        analyzeMainTag()
        analyzeSecondaryTag()
        analyzeValueTag()
        
        let result = AnalyzeResult()
        if let nameTag = nameTag {
            result.name = nameTag.word
        }
        if let eventTag = eventTag {
            result.event = eventTag.word
        }
        if let relationTag = relationTag {
            result.relation = relationTag.word
        }
        result.type = type
        if unitType == .gift {
            result.unitType = .gift
            if let giftName = giftNameTag, let giftValue = valueTag {
                result.giftName = giftName.word
                result.unit = giftUnitTag?.word ?? "个"
                result.value = giftValue.word
            } else {
                result.error = CommonError(message: "无法理解您的意思，请您尽量按照例句表达")
            }
        } else {
            result.unitType = .money
            if let valueTag = valueTag {
                result.value = valueTag.word
                result.unit = "元"
            } else {
                result.error = CommonError(message: "无法理解您的意思，请您尽量按照例句表达")
            }
        }
        return result
    }
    
    func analyzeMainTag() {
        for (index, tag) in analyzeTags.enumerated() {
            tag.index = index
            if WordAnalyzeHelp.shared.isName(word: tag.word) {
                var confidence: Float = Float(tag.word.count) * 2.0
                for name in WordAnalyzeHelp.shared.nameWords {
                    if let firstIndex = tag.word.range(of: name)?.lowerBound {
                        if firstIndex.utf16Offset(in: tag.word) == 0 {
                            confidence += 4
                            break
                        }
                    }
                }
                if tag.jieBaTag == "relation" || tag.jieBaTag == "event" {
                    confidence = -1
                }
                if tag.jieBaTag == "nr" {
                    confidence += 3
                }
                if tag.jieBaTag == "n" {
                    confidence += 1
                }
                if let oldTag = nameTag {
                    if oldTag.confidence < confidence, tag.confidence < confidence {
                        tag.confidence = confidence
                        tag.type = .name
                    }
                } else {
                    tag.confidence = confidence
                    tag.type = .name
                }
            }
            if WordAnalyzeHelp.shared.isMoneyUnit(word: tag.word) {
                var confidence: Float = 5.0
                if ["¥", "元"].contains(tag.word) {
                    confidence += 10
                }
                if let oldTag = moneyUnitTag {
                    if oldTag.confidence < confidence, tag.confidence < confidence {
                        tag.confidence = confidence
                        tag.type = .moneyUnit
                    }
                } else {
                    tag.confidence = confidence
                    tag.type = .moneyUnit
                }
            }
            if WordAnalyzeHelp.shared.isGiftUnit(word: tag.word) {
                var confidence: Float = 7.0
                if tag.word.count > 3 {
                    confidence = 0
                }
                confidence -= Float(abs(1 - tag.word.count))
                if tag.jieBaTag == "m" {
                    confidence += 3
                }
                if tag.jieBaTag == "q" {
                    confidence += 4
                }
                if let oldTag = giftUnitTag {
                    if oldTag.confidence < confidence, tag.confidence < confidence {
                        tag.confidence = confidence
                        tag.type = .giftUnit
                    }
                } else {
                    tag.confidence = confidence
                    tag.type = .giftUnit
                }
            }
            printAnalyzeTags()
        }
    }
    func analyzeSecondaryTag() {
        for (index, tag) in analyzeTags.enumerated() {
            if WordAnalyzeHelp.shared.isGiftNameWords(word: tag.word) {
                var confidence: Float = 2.0
                if tag.jieBaTag == "n" {
                    confidence += 2
                }
                confidence += Float(tag.word.count)
                if let giftUnitTag = giftUnitTag {
                    if giftUnitTag.index == index {
                        confidence = -1
                    } else {
                        confidence += Float(4 - abs(giftUnitTag.index - index))
                    }
                } else {
                    confidence += Float(index)/10
                }
                
                if let oldTag = giftNameTag {
                    if oldTag.confidence < confidence, tag.confidence < confidence {
                        tag.confidence = confidence
                        tag.type = .giftName
                    }
                } else if confidence > 0 {
                    tag.confidence = confidence
                    tag.type = .giftName
                }
            }
            if WordAnalyzeHelp.shared.isRelationWords(word: tag.word) {
                var confidence: Float = 5.0
                if tag.jieBaTag == "n" {
                    confidence += 2
                } else if tag.jieBaTag == "relation" {
                    confidence += 10
                }
                if let oldTag = relationTag {
                    if oldTag.confidence < confidence, tag.confidence < confidence {
                        tag.confidence = confidence
                        tag.type = .relationName
                    }
                } else {
                    tag.confidence = confidence
                    tag.type = .relationName
                }
            }
            if WordAnalyzeHelp.shared.isEventWords(word: tag.word) {
                var confidence: Float = 4.0
                if tag.jieBaTag == "n" {
                    confidence += 2
                } else if tag.jieBaTag == "event" {
                    confidence += 5
                }
                if let oldTag = eventTag {
                    if oldTag.confidence < confidence, tag.confidence < confidence {
                        tag.confidence = confidence
                        tag.type = .eventName
                    }
                } else {
                    tag.confidence = confidence
                    tag.type = .eventName
                }
            }
            if type == nil, WordAnalyzeHelp.shared.isInAccountWords(word: tag.word) {
                if tag.type == nil && tag.confidence < 6 {
                    type = .inAccount
                }
            } else if type == nil, WordAnalyzeHelp.shared.isOutAccountWords(word: tag.word) {
                if tag.type == nil && tag.confidence < 6 {
                    type = .outAccount
                }
            }
            printAnalyzeTags()
        }
    }
    
    func analyzeValueTag() {
        if unitType == .gift, let unitTag = giftUnitTag {
            let step = 1
            while step <= 2 {
                var index = unitTag.index - step
                if index > 0 {
                    let giftValueTag = analyzeTags[index]
                    if WordAnalyzeHelp.shared.isNumberValue(word: giftValueTag.word) {
                        giftValueTag.confidence = 20
                        giftValueTag.type = .value
                        break
                    }
                }
                index = unitTag.index + step
                if index < analyzeTags.count {
                    let giftValueTag = analyzeTags[index]
                    if WordAnalyzeHelp.shared.isNumberValue(word: giftValueTag.word) {
                        giftValueTag.confidence = 20
                        giftValueTag.type = .value
                        break
                    }
                }
            }
        } else if let unitTag = moneyUnitTag {
            let step = 1
            while step <= 2 {
                var index = unitTag.index - step
                if index > 0 {
                    let moneyValueTag = analyzeTags[index]
                    if WordAnalyzeHelp.shared.isMoneyValue(word: moneyValueTag.word) {
                        moneyValueTag.confidence = 20
                        moneyValueTag.type = .value
                        break
                    }
                }
                index = unitTag.index + step
                if index < analyzeTags.count {
                    let moneyValueTag = analyzeTags[index]
                    if WordAnalyzeHelp.shared.isMoneyValue(word: moneyValueTag.word) {
                        moneyValueTag.confidence = 20
                        moneyValueTag.type = .value
                        break
                    }
                }
            }
        }
        printAnalyzeTags()
    }
    
    func printAnalyzeTags() {
        #if DEBUG
        let str = analyzeTags.reduce("") { (str, tag) -> String in
            return "\(str)\(tag.string)  "
        }
        print(str)
        #endif
    }
}
