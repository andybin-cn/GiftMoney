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
    var eventTime: Date? = nil
    var relation: String = ""
    var originSentence: String = ""
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
    var analyzeTags: [AnalyzeTag]
    var sentence: String
    var eventTime: Date?
    init(sentence: String) {
        self.sentence = sentence
        analyzeTags = [AnalyzeTag]()
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
    var lastNameTag: AnalyzeTag?
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
        let result = AnalyzeResult()
        self.sentence = takeOutEventTime(sentence: self.sentence)
        guard let tags = JieBaBridge.jiebaTag(sentence) as? Array<JieBaTag> else {
            result.error = CommonError(message: "无法理解您的意思，请您尽量按照例句表达")
            return result
        }
        self.analyzeTags = tags.map{ AnalyzeTag(tag: $0) }
        
        analyzeTradeUnitTag()
        printAnalyzeTags()
        
        analyzeValueTag()
        printAnalyzeTags()
        
        analyzePepoleNameTag()
        printAnalyzeTags()
        
        analyzeRelationTag()
        printAnalyzeTags()
        
        analyzeEventTag()
        printAnalyzeTags()
        
        analyzeGiftNameTag()
        printAnalyzeTags()
        
        analyzeInOutTag()
        printAnalyzeTags()
        
        analyzePepoleLastNameTag()
        printAnalyzeTags()
        
        
        if let nameTag = nameTag {
            result.name = nameTag.word
            if let lastName = self.lastNameTag {
                result.name += lastName.word
            }
        }
        if let eventTag = eventTag {
            result.event = eventTag.word
        }
        if let relationTag = relationTag {
            result.relation = relationTag.word
        }
        result.type = type
        result.eventTime = eventTime
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
    func analyzeTradeUnitTag() {
        for (index, tag) in analyzeTags.enumerated() {
            tag.index = index
            if WordAnalyzeHelp.shared.isMoneyUnit(word: tag.word) {
                var confidence: Float = 5.0
                if "¥" == tag.word {
                    confidence += 20
                } else if "元" == tag.word {
                    confidence += 10
                } else if "红包" == tag.word {
                    confidence += 9
                } else if "块" == tag.word {
                    confidence += min(Float(index), 5)
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
        }
    }
    
    func analyzePepoleNameTag() {
        guard let unitTag = unitType == .money ? moneyUnitTag : giftUnitTag else {
            return
        }
        for (index, tag) in analyzeTags.enumerated() {
            if unitTag.index == index {
                continue
            }
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
                if tag.type == .giftUnit {
                    confidence -= 3
                }
                if tag.jieBaTag == "relation" || tag.jieBaTag == "event" {
                    confidence = -2
                }
                if tag.jieBaTag == "h" {
                    confidence += 2
                }
                if tag.jieBaTag == "nr" {
                    confidence += 3
                }
                if index > unitTag.index {
                    confidence -= 1
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
        }
    }
    func analyzePepoleLastNameTag() {
        guard let nameTag = self.nameTag, nameTag.word.count == 1 else {
            return
        }
        let lastNameTagIndex = nameTag.index + 1
        if lastNameTagIndex >= analyzeTags.count {
            return
        }
        let lastNameTag = analyzeTags[lastNameTagIndex]
        if lastNameTag.type != nil || lastNameTag.confidence >= 0 {
            return
        }
        self.lastNameTag = lastNameTag
    }
    
    func analyzeRelationTag() {
        for (_, tag) in analyzeTags.enumerated() {
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
        }
    }
    func analyzeEventTag() {
        for (_, tag) in analyzeTags.enumerated() {
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
        }
    }
    func analyzeInOutTag() {
        for tag in analyzeTags {
            if type == nil, WordAnalyzeHelp.shared.isInAccountWords(word: tag.word) {
                tag.confidence = 1
                type = .inAccount
                break
            }
            if type == nil, WordAnalyzeHelp.shared.isOutAccountWords(word: tag.word) {
                tag.confidence = 1
                type = .outAccount
                break
            }
        }
    }
    func analyzeGiftNameTag() {
        guard unitType == .gift, let value = valueTag else {
            return
        }
        let nameTag = self.nameTag
        let eventTag = self.eventTag
        let relationTag = self.relationTag
        let unitTag = giftUnitTag
        for step in 1...2 {
            var index = value.index - step
            if nameTag?.index == index || eventTag?.index == index || relationTag?.index == index || value.index == index || unitTag?.index == index {
                continue
            }
            if index > 0 {
                let giftNameTag = analyzeTags[index]
                if WordAnalyzeHelp.shared.isGiftNameWords(word: giftNameTag.word) {
                    var confidence: Float = Float(6 - step)
                    if giftNameTag.jieBaTag == "n" {
                        confidence += 2
                    }
                    giftNameTag.confidence = confidence
                    giftNameTag.type = .giftName
                }
            }
            index = value.index + step
            if nameTag?.index == index || eventTag?.index == index || relationTag?.index == index || value.index == index || unitTag?.index == index {
                continue
            }
            if index < analyzeTags.count {
                let giftNameTag = analyzeTags[index]
                if WordAnalyzeHelp.shared.isGiftNameWords(word: giftNameTag.word) {
                    var confidence = Float(5 + step)
                    if giftNameTag.jieBaTag == "n" {
                        confidence += 2
                    }
                    giftNameTag.confidence = confidence
                    giftNameTag.type = .giftName
                }
            }
        }
    }
    
    func analyzeValueTag() {
        if unitType == .gift, let unitTag = giftUnitTag {
            for step in 1...2 {
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
            for step in 1...2 {
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
    }
    
    func takeOutEventTime(sentence: String) -> String {
        let regex = try! NSRegularExpression(pattern: "[0-9]+[年|/|-| ][0-9]+[月|/|-| ]([0-9]+[|日|号|/|-| ])?", options:[])
        let matches = regex.matches(in: sentence, options: [], range: NSRange(sentence.startIndex...,in: sentence))
        if matches.count >= 1 {
            let dateStr = String(sentence[Range(matches[0].range, in: sentence)!])
            eventTime = dateStr.toDate()
            return sentence.replacingOccurrences(of: dateStr, with: " ")
        }
        return sentence
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
