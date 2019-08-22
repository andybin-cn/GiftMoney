//
//  InoutRecordsViewController.swift
//  GiftMoney
//
//  Created by binea on 2019/8/4.
//  Copyright © 2019 binea. All rights reserved.
//

import UIKit
import Common

class InAccountTradeVC: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableView = UITableView()
    var trades = [Trade]()
    var event: Event?
    
    init(event: Event? = nil, trades: [Trade]? = nil) {
        self.event = event
        self.trades = trades ?? [Trade]()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "收支记录"
        
        let addRecordButton = UIBarButtonItem(title: "新增", style: UIBarButtonItem.Style.plain, target: self, action: #selector(addRecordButtonTapped))
        self.navigationItem.rightBarButtonItems = [addRecordButton]
        
        
        tableView.apply { (tableView) in
            tableView.register(TradeCell.self, forCellReuseIdentifier: TradeCell.commonIdentifier)
            tableView.estimatedRowHeight = 80
            tableView.delegate = self
            tableView.dataSource = self
            tableView.setExtraCellLineHidden()
            
            tableView.addTo(self.view) { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    @objc func addRecordButtonTapped() {
        navigationController?.pushViewController(AddTradeViewController(tradeType: Trade.TradeType.inAccount, event: event), animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }
    
    func loadData() {
        if let event = self.event {
            if let time = event.time {
                let daySecends = 60 * 60 * 24
                let minTime = Int(time.timeIntervalSince1970) / daySecends * daySecends
                let maxtime = minTime + daySecends
                let minDate = NSDate(timeIntervalSince1970: TimeInterval(minTime))
                let maxDate = NSDate(timeIntervalSince1970: TimeInterval(maxtime))
                trades = RealmManager.share.realm.objects(Trade.self).filter(
                    NSPredicate(format: "typeString == %@ AND eventName == %@ AND eventTime >= %@ AND eventTime < %@", Trade.TradeType.inAccount.rawValue, event.name, minDate, maxDate)).sorted(byKeyPath: "updateTime", ascending: false).map{ $0 }
            } else {
                trades = RealmManager.share.realm.objects(Trade.self).filter(NSPredicate(format: "typeString == %@ AND eventName == %@", Trade.TradeType.inAccount.rawValue, event.name)).sorted(byKeyPath: "eventTime", ascending: false).map{ $0 }
            }
        } else {
            trades = RealmManager.share.realm.objects(Trade.self).filter(NSPredicate(format: "typeString == %@ AND eventName != ''", Trade.TradeType.inAccount.rawValue)).sorted(byKeyPath: "eventTime", ascending: false).map{ $0 }
        }
        tableView.reloadData()
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trades.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TradeCell.commonIdentifier, for: indexPath) as! TradeCell
        cell.selectionStyle = .none
        let trade = trades[indexPath.row]
        cell.configerUI(trade: trade)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let trade = trades[indexPath.row]
        let controller = AddTradeViewController(trade: trade)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let trade = trades[indexPath.row]
        self.showAlertView(title: "确定删除记录【\(trade.name)】么？", message: nil, actions: [
            UIAlertAction(title: "取消", style: .cancel, handler: nil),
            UIAlertAction(title: "删除", style: .destructive, handler: { (_) in
                self.showLoadingIndicator()
                TradeManger.shared.deleteTrade(trade: trade).subscribe(onCompleted: { [weak self] in
                    self?.hiddenLoadingIndicator()
                    self?.trades.remove(at: indexPath.row)
                    tableView.reloadData()
                }) { [weak self] (error) in
                    self?.showTipsView(text: error.localizedDescription)
                }.disposed(by: self.disposeBag)
            })
        ])
    }
}
