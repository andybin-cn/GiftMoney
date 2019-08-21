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
    
    
}
