//
//  XLSXManager.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/21.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import RxSwift
import Common


private class XLSHeader {
    var uuid = ""
    var name = ""
    var relation = ""
    var type = ""
    var eventName = ""
    var eventTime = ""
    var totoalMoney = ""
    var remark = ""
    var createTime = ""
    var updateTime = ""
    var tradeItems = ""
    var tradeMedias = ""
    
    let idCloums: Set<String> = ["ID", "UUID", "Id", "uuid", "id"]
    let nameCloums: Set<String> = ["姓名", "名字"]
    let relationCloums: Set<String> = ["关系"]
    let typeCloums: Set<String> = ["类型", "类别", "收支"]
    let eventNameCloums: Set<String> = ["事件", "事件名称"]
    let eventTimeCloums: Set<String> = ["事件时间"]
    let totoalMoneyCloums: Set<String> = ["金额", "红包", "总金额(元)", "总金额"]
    let remarkCloums: Set<String> = ["备注"]
    let createTimeCloums: Set<String> = ["创建时间"]
    let updateTimeCloums: Set<String> = ["最近修改时间", "修改时间"]
    let tradeItemsCloums: Set<String> = ["记录详情"]
    let tradeMediasCloums: Set<String> = ["图片和视频"]
    
    init(worksheet: BRAWorksheet) {
        let columns: [String] = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
        for column in columns {
            guard let cell = worksheet.cell(forCellReference: "\(column)1"), !cell.hasError, let value = cell.stringValue(), !value.isEmpty else {
                continue
            }
            if idCloums.contains(value) {
                self.uuid = column
            }
            if nameCloums.contains(value) {
                self.name = column
            }
            if relationCloums.contains(value) {
                self.relation = column
            }
            if typeCloums.contains(value) {
                self.type = column
            }
            if eventNameCloums.contains(value) {
                self.eventName = column
            }
            if eventTimeCloums.contains(value) {
                self.eventTime = column
            }
            if totoalMoneyCloums.contains(value) {
                self.totoalMoney = column
            }
            if remarkCloums.contains(value) {
                self.remark = column
            }
            if createTimeCloums.contains(value) {
                self.createTime = column
            }
            if updateTimeCloums.contains(value) {
                self.updateTime = column
            }
            if tradeItemsCloums.contains(value) {
                self.tradeItems = column
            }
            if tradeMediasCloums.contains(value) {
                self.tradeMedias = column
            }
        }
    }
    
}

private class XLSBodyPaser {
    let worksheet: BRAWorksheet
    let header: XLSHeader
    init(worksheet: BRAWorksheet) {
        header = XLSHeader(worksheet: worksheet)
        self.worksheet = worksheet
    }
    
    func cell(forColumn column: String, row: Int) -> BRACell? {
        if column.isEmpty {
            return nil
        }
        if row <= 0 {
            return nil
        }
        guard let cell = worksheet.cell(forCellReference: "\(column)\(row)"), !cell.hasError else {
            return nil
        }
        return cell
    }
    
    func dateTime(forCell cell: BRACell) -> Date? {
        if let date = cell.dateValue() {
            return date
        }
        if cell.stringValue() == "General", let originValue = cell.originValue(), let dateValue = TimeInterval(originValue), let since = "1900-1-1".toDate(withFormat: "yyyy-MM-dd") {
            //mac导出的Excel格式无法识别，需要自己处理一下，详情参见Excel的datevalue函数
            return Date(timeInterval: (dateValue - 1) * 24 * 60 * 60, since: since)
        }
        return cell.stringValue()?.toDate()
    }
    
    func stringValue(forCell cell: BRACell) -> String? {
        if cell.stringValue() == "General" {
            return cell.originValue()
        }
        return cell.stringValue()
    }
    
    func uuid(forRow index: Int) -> String? {
        guard let cell = cell(forColumn: header.uuid, row: index) else {
            return nil
        }
        return stringValue(forCell: cell)
    }
    func name(forRow index: Int) -> String {
        guard let cell = cell(forColumn: header.name, row: index) else {
            return ""
        }
        return stringValue(forCell: cell) ?? ""
    }
    func relation(forRow index: Int) -> String? {
        guard let cell = cell(forColumn: header.relation, row: index) else {
            return nil
        }
        return stringValue(forCell: cell)
    }
    func type(forRow index: Int) -> Trade.TradeType {
        guard let cell = cell(forColumn: header.type, row: index), let value = stringValue(forCell: cell) else {
            return Trade.TradeType.inAccount
        }
        if let _ = ["出", "送", "支", "out"].findFirst(predicate: { (keyWord) -> Bool in
            return value.contains(keyWord)
        }) {
            return Trade.TradeType.outAccount
        }
        return Trade.TradeType.inAccount
    }
    func eventName(forRow index: Int) -> String {
        guard let cell = cell(forColumn: header.eventName, row: index) else {
            return ""
        }
        return stringValue(forCell: cell) ?? ""
    }
    func eventTime(forRow index: Int) -> Date? {
        guard let cell = cell(forColumn: header.eventTime, row: index) else {
            return nil
        }
        return dateTime(forCell: cell)
    }
    func totoalMoney(forRow index: Int) -> String? {
        guard let cell = cell(forColumn: header.totoalMoney, row: index) else {
            return nil
        }
        return stringValue(forCell: cell)
    }
    func remark(forRow index: Int) -> String? {
        guard let cell = cell(forColumn: header.remark, row: index) else {
            return nil
        }
        return stringValue(forCell: cell)
    }
    func createTime(forRow index: Int) -> Date? {
        guard let cell = cell(forColumn: header.createTime, row: index) else {
            return nil
        }
        return dateTime(forCell: cell)
    }
    func updateTime(forRow index: Int) -> Date? {
        guard let cell = cell(forColumn: header.updateTime, row: index) else {
            return nil
        }
        return dateTime(forCell: cell)
    }
    func tradeItems(forRow index: Int) -> [TradeItem] {
        guard let cell = cell(forColumn: header.tradeItems, row: index) else {
            return [TradeItem]()
        }
        let value = stringValue(forCell: cell) ?? ""
        return [TradeItem].init(JSONString: value) ?? [TradeItem]()
    }
    func tradeMedias(forRow index: Int) -> [TradeMedia] {
        guard let cell = cell(forColumn: header.tradeMedias, row: index) else {
            return [TradeMedia]()
        }
        let value = stringValue(forCell: cell) ?? ""
        return [TradeMedia].init(JSONString: value) ?? [TradeMedia]()
    }
}

class XLSXManager {
    
    static let shared = XLSXManager()
    
    private init() {
        
    }
    
    func exportXLSX() -> Observable<URL> {
        let workPath = "\(NSTemporaryDirectory())excelExport"
        let fileName = "礼金小助手-Excel-\(Date().toString(withFormat: "MM月dd日HH-mm")).xlsx"
        let fileUrl = URL(fileURLWithPath: "\(workPath)/\(fileName)")
        return Observable<URL>.create { (observable) -> Disposable in
            var inCancel = false
            DispatchQueue.global().async {
                do {
                    if FileManager.default.fileExists(atPath: workPath) {
                        let contentsOfPath = try FileManager.default.contentsOfDirectory(atPath: workPath)
                        try contentsOfPath.forEach { (content) in
                            try FileManager.default.removeItem(atPath: "\(workPath)/\(content)")
                        }
                    }
                    try FileManager.default.createDirectory(atPath: workPath, withIntermediateDirectories: true, attributes: nil)
                } catch _ { }
                
                let trades = RealmManager.share.realm.objects(Trade.self).filter(NSPredicate(format: "typeString != '' AND eventName != ''"))
                let file = NSString(format: "%@", fileUrl.path)
                let workbook = new_workbook(file.fileSystemRepresentation)
                guard let worksheet1 = workbook_add_worksheet(workbook, "礼金小助手") else {
                    DispatchQueue.main.async {
                        observable.onError(CommonError(message: "创建文件失败"))
                    }
                    return
                }
                let headers = ["uuid", "姓名", "关系", "类别", "事件名称", "事件时间", "总金额(元)", "备注", "创建时间", "最近修改时间", "记录详情", "图片和视频"]
                
                headers.enumerated().forEach { (arg0) in
                    let (index, name) = arg0
                    worksheet_write_string(worksheet1, 0, lxw_col_t(index), name, nil)
                }
                for (index, trade) in trades.enumerated() {
                    if inCancel {
                        break
                    }
                    self.save(trade: trade, to: worksheet1, index: index)
                }
                workbook_close(workbook)
                DispatchQueue.main.async {
                    observable.onNext(fileUrl)
                    observable.onCompleted()
                }
            }
            return Disposables.create {
                inCancel = true
            }
        }
    }
    
    func save(trade: Trade, to worksheet: UnsafeMutablePointer<lxw_worksheet>?, index: Int) {
        let tradeItems: [TradeItem] = trade.tradeItems.map { $0 }
        let tradeMedias: [TradeMedia] = trade.tradeMedias.map{ $0 }
        RealmManager.share.realm.beginWrite()
        let tradeItemsValue: String = tradeItems.toJSONString(prettyPrint: false) ?? ""
        let tradeMediasValue: String = tradeMedias.toJSONString(prettyPrint: false) ?? ""
        RealmManager.share.realm.cancelWrite()
        
        let values: [String] = [
            trade.id,
            trade.name,
            trade.relationship,
            trade.type?.rawValue ?? "",
            trade.eventName,
            trade.eventTime.toString(withFormat: "yyyy-MM-dd"),
            String(format: "%0.0f", trade.totalMoney),
            trade.remark,
            trade.createTime.toString(withFormat: "yyyy-MM-dd"),
            trade.updateTime.toString(withFormat: "yyyy-MM-dd"),
            tradeItemsValue,
            tradeMediasValue,
        ]
        
        values.enumerated().forEach { (col, item) in
            worksheet_write_string(worksheet, lxw_row_t(index + 1), lxw_col_t(col), item, nil)
        }
    }
    
    func importFromXLSX(url: URL) -> Observable<Int> {
        return Observable<Int>.create { (observable) -> Disposable in
            let workPath = "\(NSTemporaryDirectory())excelImport"
            let tempUrlPath = "\(workPath)/\(UUID().uuidString).\(url.pathExtension)"
            let tempUrl = URL(fileURLWithPath: tempUrlPath)
            DispatchQueue.global().async {
                do {
                    if FileManager.default.fileExists(atPath: workPath) {
                        let contentsOfPath = try FileManager.default.contentsOfDirectory(atPath: workPath)
                        try contentsOfPath.forEach { (content) in
                            try FileManager.default.removeItem(atPath: "\(workPath)/\(content)")
                        }
                    }
                    try FileManager.default.createDirectory(atPath: workPath, withIntermediateDirectories: true, attributes: nil)
                    try FileManager.default.copyItem(at: url, to: tempUrl)
                } catch let error {
                    DispatchQueue.main.async {
                        observable.onError(error)
                    }
                    return
                }
                let spreadsheet = BRAOfficeDocumentPackage.open(tempUrl.path)
                guard let firstWorksheet = spreadsheet?.workbook?.worksheets?.first as? BRAWorksheet else {
                    DispatchQueue.main.async {
                        observable.onError(CommonError(message: "无法识别的文件"))
                    }
                    return
                }
                let parser = XLSBodyPaser(worksheet: firstWorksheet)
                var trades = [Trade]()
                var index = 2
                while !parser.name(forRow: index).isEmpty, !parser.eventName(forRow: index).isEmpty {
                    let trade = Trade()
                    trade.id = parser.uuid(forRow: index) ?? UUID().uuidString
                    trade.name = parser.name(forRow: index)
                    trade.relationship = parser.relation(forRow: index) ?? ""
                    trade.type = parser.type(forRow: index)
                    trade.eventName = parser.eventName(forRow: index)
                    trade.eventTime = parser.eventTime(forRow: index) ?? Date()
                    trade.remark = parser.remark(forRow: index) ?? ""
                    trade.createTime = parser.createTime(forRow: index) ?? Date()
                    trade.updateTime = parser.updateTime(forRow: index) ?? Date()
                    var tradeItems = parser.tradeItems(forRow: index)
                    let tradeMedias = parser.tradeMedias(forRow: index)
                    
                    let totalMoneyStr = parser.totoalMoney(forRow: index) ?? "0"
                    
                    index += 1
                    if RealmManager.share.realm.object(ofType: Trade.self, forPrimaryKey: trade.id) != nil {
                        continue
                    }
                    
                    let tradeItemsMoney = tradeItems.reduce(0.0) { (r, item) -> Float in
                        guard item.type == .money, let money = Float(item.value) else {
                            return r
                        }
                        return r + money
                    }
                    let totalMoney = Float(totalMoneyStr) ?? 0
                    if (tradeItems.count == 0 || tradeItemsMoney != totalMoney ), totalMoney > 0 {
                        let item = TradeItem()
                        item.type = .money
                        item.value = String(format: "%0.0f", totalMoney)
                        tradeItems = [item] + tradeItems.filter{ $0.type == .gift }
                    }
                    trade.tradeItems.append(objectsIn: tradeItems)
                    trade.tradeMedias.append(objectsIn: tradeMedias)
                    
                    do {
                        RealmManager.share.realm.beginWrite()
                        RealmManager.share.realm.add(trade)
                        try RealmManager.share.realm.commitWrite()
                        trades.append(trade)
                    } catch _ {
                        SLog.info("RealmManager error:")
                    }
                }
                let count = trades.count
                DispatchQueue.main.async {
                    observable.onNext(count)
                    observable.onCompleted()
                }
            }
            return Disposables.create {
                do {
                    try FileManager.default.removeItem(at: tempUrl)
                } catch _ {
                    
                }
            }
        }
    }
}
