//
//  OutAccountTradeVC.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/13.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import Common
import DZNEmptyDataSet

class OutAccountTradeVC: BaseViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, TradeFunctionHeaderDelegate {
    
    let tableView = UITableView()
    var trades = [Trade]()
    let header = TradeFunctionHeader(frame: CGRect(x: 0, y: 0, width: ScreenHelp.windowWidth, height: 70))
    
    var filter: FilterOption?
    var sortType: TradeFuntionSort?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.apply { (tableView) in
            tableView.register(TradeCell.self, forCellReuseIdentifier: TradeCell.commonIdentifier)
            tableView.estimatedRowHeight = 80
            tableView.delegate = self
            tableView.dataSource = self
            tableView.setExtraCellLineHidden()
            tableView.emptyDataSetSource = self
            tableView.emptyDataSetDelegate = self
            tableView.tableHeaderView = header
            header.delegate = self
            header.parentView = MainTabViewController.shared.view
            
            tableView.addTo(self.view) { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    @objc func addRecordButtonTapped() {
        navigationController?.pushViewController(AddTradeViewController(tradeType: .outAccount, event: nil), animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }
    
    func loadData() {
        self.trades = TradeManger.shared.searchTrades(tradeType: .outAccount, filter: filter, sortType: sortType)
        var totoalAmount: Float = 0.0
        var giftCount = 0
        trades.forEach { (trade) in
            totoalAmount += trade.totalMoney
            giftCount += trade.giftCount
        }
        header.label1.text = String(format: "送出金额 ¥%0.0f元", totoalAmount)
        header.label2.text = String(format: "送出礼物 %d 件", giftCount)
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
    //MARK: - DZNEmptyDataSetDelegate DZNEmptyDataSetSource
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "icons8-paper_plane")
    }
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "你还没有送出过份子钱？快来记一下吧！", attributes: [NSAttributedString.Key.font : UIFont.appFont(ofSize: 14)])
    }
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControl.State) -> NSAttributedString! {
        return NSAttributedString(string: "添加记录", attributes: [NSAttributedString.Key.font : UIFont.appFont(ofSize: 20), NSAttributedString.Key.foregroundColor: UIColor.appSecondaryYellow])
    }
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        navigationController?.pushViewController(AddTradeViewController(tradeType: .outAccount, event: nil), animated: true)
    }
    
    //MARK: - TradeFunctionHeaderDelegate
    
    func functionHeaderChanged(header: TradeFunctionHeader, filter: FilterOption, sortType: TradeFuntionSort) {
        self.filter = filter
        self.sortType = sortType
        loadData()
    }
}

