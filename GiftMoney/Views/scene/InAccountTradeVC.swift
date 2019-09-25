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
    var sortType: TradeFuntionSort
    var shouldRefreshWhenAppear = false
    
    init(sortType: TradeFuntionSort, event: Event? = nil, trades: [Trade]? = nil) {
        self.event = event
        self.trades = trades ?? [Trade]()
        self.sortType = sortType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = event?.name ?? "入账流水"
        
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
        if shouldRefreshWhenAppear {
            loadData()
        }
        shouldRefreshWhenAppear = true
    }
    
    func loadData() {
        trades = TradeManger.shared.searchTrades(event: self.event, tradeType: .inAccount, sortType: self.sortType)
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
                TradeManger.shared.deleteTrade(tradeID: trade.id).subscribe(onError: { [weak self] (error) in
                    self?.catchError(error: error)
                }, onCompleted: { [weak self] in
                    self?.hiddenLoadingIndicator()
                    self?.trades.remove(at: indexPath.row)
                    tableView.reloadData()
                }).disposed(by: self.disposeBag)
            })
        ])
    }
}
