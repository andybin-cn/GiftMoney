//
//  InAccountEventGroupVC.swift
//  GiftMoney
//
//  Created by binea on 2019/8/18.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import UIKit

class InAccountEventGroupVC: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
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
        cell.textLabel?.text = event.name
        cell.detailTextLabel?.text = event.time?.toString(withFormat: "yyyy-MM-dd")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let event = keys[indexPath.row]
        let trades = eventsGroup[event]
        let controller = InAccountTradeVC(event: event, trades: trades)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
