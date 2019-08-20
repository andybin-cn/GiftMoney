//
//  SearchTradeVC.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/19.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import UIKit

class SearchTradeVC: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    let inputField = UITextField()
    let tableView = UITableView()
    var trades: [Trade] = [Trade]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputField.apply { (inputField) in
            inputField.leftViewMode = .always
            let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
            let icon = UIImageView(frame: CGRect(x: 8, y: 8, width: 20, height: 20))
            icon.image = UIImage(named: "icons8-search")
            containerView.addSubview(icon)
            inputField.leftView = containerView
            inputField.frame = CGRect(x: 0, y: 0, width: ScreenHelp.windowWidth - 160, height: 36)
            inputField.layer.cornerRadius = 18
            inputField.layer.masksToBounds = true
            inputField.layer.borderWidth = 0.5
            inputField.layer.borderColor = UIColor.appGrayLine.cgColor
            inputField.backgroundColor = UIColor.appGrayBackground
            inputField.placeholder = "关键字搜索"
        }
        
        navigationItem.titleView = inputField
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "搜索", style: .done, target: self, action: #selector(onSearchButtonTapped))
        
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
    
    @objc func onSearchButtonTapped() {
        searchTrade(keyword: inputField.text ?? "")
    }
    
    func searchTrade(keyword: String) {
        trades = TradeManger.shared.searchTrade(keyword: keyword)
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
