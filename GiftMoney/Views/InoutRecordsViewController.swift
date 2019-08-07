//
//  InoutRecordsViewController.swift
//  GiftMoney
//
//  Created by binea on 2019/8/4.
//  Copyright © 2019 binea. All rights reserved.
//

import UIKit
import Common

class InoutRecordsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableView = UITableView()
    var trades = [Trade]()
    
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
            
            tableView.addTo(self.view) { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    override func addNavigationBar() {
        super.addNavigationBar()
        let commitButton = UIButton().then { (button) in
            button.setTitle("新增", for: .normal)
            button.setEnlargeEdge(top: 10, right: 20, bottom: 10, left: 15)
            button.addTarget(self, action: #selector(addRecordButtonTapped), for: UIControl.Event.touchUpInside)
        }
        navigationBar.addSubview(commitButton) { (make) in
            make.right.equalTo(-15)
            make.centerY.equalToSuperview().offset(10)
        }
    }
    
    @objc func addRecordButtonTapped() {
        
        navigationController?.pushViewController(AddTradeViewController(), animated: true)
    }
    
    func loadData() {
        trades = RealmManager.share.realm.objects(Trade.self).filter { _ in true }
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
    
}
