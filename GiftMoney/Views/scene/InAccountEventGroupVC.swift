//
//  InAccountEventGroupVC.swift
//  GiftMoney
//
//  Created by binea on 2019/8/18.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import UIKit
import DZNEmptyDataSet

class InAccountEventGroupVC: BaseViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, TradeFunctionHeaderDelegate {
    
    let tableView = UITableView()
    var eventsGroup = Dictionary<Event, [Trade]>()
    var keys = [Event]()
    
    let header = TradeFunctionHeader(frame: CGRect(x: 0, y: 0, width: ScreenHelp.windowWidth, height: 70))
    
    var filter: FilterOption?
    var sortType: TradeFuntionSort?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.apply { (tableView) in
            tableView.register(EventGroupCell.self, forCellReuseIdentifier: EventGroupCell.commonIdentifier)
            tableView.estimatedRowHeight = 80
            tableView.delegate = self
            tableView.dataSource = self
            tableView.setExtraCellLineHidden()
            tableView.emptyDataSetDelegate = self
            tableView.emptyDataSetSource = self
            tableView.tableHeaderView = header
            header.delegate = self
            header.parentView = MainTabViewController.shared.view
            
            tableView.addTo(view) { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }
    
    func loadData() {
        let trades = TradeManger.shared.searchTrades(tradeType: .inAccount, filter: filter, sortType: sortType)
        let sortType = self.sortType ?? TradeFuntionSort.timeDescending
        eventsGroup = TradeManger.shared.eventsGroup(trades: trades)
        
        keys = eventsGroup.keys.sorted { (a, b) -> Bool in
            switch sortType {
            case .timeDescending:
                guard let t1 = a.time else {
                    return false
                }
                guard let t2 = b.time else {
                    return true
                }
                return t1 > t2
            case .timeAscending:
                guard let t1 = a.time else {
                    return false
                }
                guard let t2 = b.time else {
                    return true
                }
                return t1 > t2
            case .amountDescending:
                return a.totalMoney > b.totalMoney
            case .amountAscending:
                return a.totalMoney < b.totalMoney
            }
        }
        
        var totoalAmount: Float = 0.0
        var giftCount = 0
        keys.forEach { (key) in
            totoalAmount += key.totalMoney
            giftCount += key.giftCount
        }
        header.label1.text = String(format: "收到金额 ¥%0.0f元", totoalAmount)
        header.label2.text = String(format: "收到礼物 %d 件", giftCount)
        tableView.reloadData()
    }
    
    //MARK: - UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        keys.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EventGroupCell.commonIdentifier, for: indexPath) as! EventGroupCell
        let event = keys[indexPath.row]
        cell.event = event
        cell.trades = eventsGroup[event]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let event = keys[indexPath.row]
        let trades = eventsGroup[event]
        let controller = InAccountTradeVC(event: event, trades: trades)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let event = keys[indexPath.row]
        let trades = eventsGroup[event] ?? [Trade]()
        let controller = EventGroupModifyVC(event: event, trades: trades)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK: - DZNEmptyDataSetDelegate DZNEmptyDataSetSource
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "icons8-paper_plane")
    }
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "你还没有收到过份子钱？总有一天会赚回来的！", attributes: [NSAttributedString.Key.font : UIFont.appFont(ofSize: 14)])
    }
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControl.State) -> NSAttributedString! {
        return NSAttributedString(string: "添加记录", attributes: [NSAttributedString.Key.font : UIFont.appFont(ofSize: 20), NSAttributedString.Key.foregroundColor: UIColor.appSecondaryYellow])
    }
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        navigationController?.pushViewController(AddTradeViewController(tradeType: .inAccount, event: nil), animated: true)
    }
    
    //MARK: - TradeFunctionHeaderDelegate
    
    func functionHeaderChanged(header: TradeFunctionHeader, filter: FilterOption, sortType: TradeFuntionSort) {
        self.filter = filter
        self.sortType = sortType
        loadData()
    }
}
