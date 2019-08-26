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

class InAccountEventGroupVC: BaseViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    let tableView = UITableView()
    var eventsGroup = Dictionary<Event, [Trade]>()
    var keys = [Event]()
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
            
            tableView.addTo(view) { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        eventsGroup = TradeManger.shared.eventsGroup()
        keys = eventsGroup.keys.sorted { (a, b) -> Bool in
            guard let t1 = a.time else {
                return false
            }
            guard let t2 = b.time else {
                return true
            }
            return t1 > t2
        }
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
}
