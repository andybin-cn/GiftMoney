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

class XLSXManager {
    static let shared = XLSXManager()
    
    func exportXLSX(fileUrl: URL) -> Observable<URL> {
        Observable<URL>.create { (observable) -> Disposable in
            var inCancel = false
            DispatchQueue.global().async {
                let trades = RealmManager.share.realm.objects(Trade.self).filter(NSPredicate(format: "typeString != '' AND eventName != ''"))
                let file = NSString(format: "%@", fileUrl.path)
                let workbook = new_workbook(file.fileSystemRepresentation)
                guard let worksheet1 = workbook_add_worksheet(workbook, "礼尚往来") else {
                    DispatchQueue.main.async {
                        observable.onError(CommonError(message: "创建文件失败"))
                    }
                    return
                }
                let headers = ["id", "name", "relationship", "eventName", "eventTime", "remark", "typeString", "createTime", "updateTime", "tradeItems", "tradeMedias"]
                
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
            trade.eventName,
            trade.eventTime.toString(withFormat: "yyyy-MM-dd"),
            trade.remark,
            trade.type?.rawValue ?? "",
            trade.createTime.toString(withFormat: "yyyy-MM-dd"),
            trade.updateTime.toString(withFormat: "yyyy-MM-dd"),
            tradeItemsValue,
            tradeMediasValue
        ]
        
        values.enumerated().forEach { (col, item) in
            worksheet_write_string(worksheet, lxw_row_t(index + 1), lxw_col_t(col), item, nil)
        }
    }
    
    func importFromXLSX(url: URL) -> Observable<Int> {
        return Observable<Int>.create { (observable) -> Disposable in
            DispatchQueue.global().async {
                let spreadsheet = BRAOfficeDocumentPackage.open(url.path)
                guard let firstWorksheet = spreadsheet?.workbook.worksheets?.first as? BRAWorksheet else {
                    DispatchQueue.main.async {
                        observable.onError(CommonError(message: "导入失败"))
                    }
                    return
                }
                var trades = [Trade]()
                var index = 1
                while let cell = firstWorksheet.cell(forCellReference: "A\(index)"), !cell.hasError, let firstValue = cell.stringValue(), !firstValue.isEmpty {
                    let trade = Trade()
                    trade.id = firstWorksheet.cell(forCellReference: "A\(index)")?.stringValue() ?? ""
                    trade.name = firstWorksheet.cell(forCellReference: "B\(index)")?.stringValue() ?? ""
                    trade.relationship = firstWorksheet.cell(forCellReference: "C\(index)")?.stringValue() ?? ""
                    trade.eventName = firstWorksheet.cell(forCellReference: "D\(index)")?.stringValue() ?? ""
                    let eventTime = firstWorksheet.cell(forCellReference: "E\(index)")?.stringValue()?.toDate(withFormat: "yyyy-MM-dd")
                    trade.remark = firstWorksheet.cell(forCellReference: "F\(index)")?.stringValue() ?? ""
                    let typeString = firstWorksheet.cell(forCellReference: "G\(index)")?.stringValue() ?? ""
                    let createTime = firstWorksheet.cell(forCellReference: "H\(index)")?.stringValue()?.toDate(withFormat: "yyyy-MM-dd")
                    let updateTime = firstWorksheet.cell(forCellReference: "I\(index)")?.stringValue()?.toDate(withFormat: "yyyy-MM-dd")
                    let tradeItemsString = firstWorksheet.cell(forCellReference: "J\(index)")?.stringValue() ?? ""
                    let tradeMediasString = firstWorksheet.cell(forCellReference: "K\(index)")?.stringValue() ?? ""
                    index += 1
                    guard let eventTime1 = eventTime, let createTime1 = createTime, let updateTime1 = updateTime else {
                        continue
                    }
                    guard let type = Trade.TradeType(rawValue: typeString) else {
                        continue
                    }
                    let tradeItems = [TradeItem].init(JSONString: tradeItemsString) ?? [TradeItem]()
                    let tradeMedias = [TradeMedia].init(JSONString: tradeMediasString) ?? [TradeMedia]()
                    
                    trade.type = type
                    trade.eventTime = eventTime1
                    trade.createTime = createTime1
                    trade.updateTime = updateTime1
                    trade.tradeItems.append(objectsIn: tradeItems)
                    trade.tradeMedias.append(objectsIn: tradeMedias)
                    
                    do {
                        RealmManager.share.realm.beginWrite()
                        RealmManager.share.realm.add(trade)
                        try RealmManager.share.realm.commitWrite()
                        trades.append(trade)
                    } catch _ {
                        
                    }
                }
                let count = trades.count
                DispatchQueue.main.async {
                    observable.onNext(count)
                    observable.onCompleted()
                }
            }
            return Disposables.create {  }
        }
    }
}
