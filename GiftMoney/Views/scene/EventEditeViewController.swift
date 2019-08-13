//
//  EventEditeViewController.swift
//  GiftMoney
//
//  Created by binea on 2019/8/11.
//  Copyright © 2019 binea. All rights reserved.
//

import UIKit

class EventEditeViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableView = UITableView()
    let inputField = UITextField()
    
    var onResult: ((_ event: Event) -> Void)?
    
    init(onResult: ((_ event: Event) -> Void)?) {
        self.onResult = onResult
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let inputView = UIView().then { (inputView) in
            inputView.backgroundColor = .appMainBackground
            inputView.addTo(view) { (make) in
                make.left.top.right.equalToSuperview()
                make.height.equalTo(40)
            }
        }
        inputField.apply { (inputField) in
            inputField.layer.cornerRadius = 16
            inputField.backgroundColor = .white
            inputField.addTo(inputView) { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(15)
                make.right.equalTo(-15)
                make.height.equalTo(32)
            }
        }
        
        tableView.apply { (tableView) in
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.commonIdentifier)
            tableView.estimatedRowHeight = 80
            tableView.delegate = self
            tableView.dataSource = self
            tableView.setExtraCellLineHidden()
            
            tableView.addTo(self.view) { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    //MARK: - ITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        if Event.latestusedEvents.count > 0 {
            return 2
        }
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Event.latestusedEvents.count > 0, section == 0  {
            return Event.latestusedEvents.count
        } else {
            return Event.systemEvents.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event: Event
        if Event.latestusedEvents.count > 0, indexPath.section == 0  {
            event = Event.latestusedEvents[indexPath.row]
        } else {
            event = Event.systemEvents[indexPath.row]
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.commonIdentifier, for: indexPath)
        cell.textLabel?.text = event.name
        cell.detailTextLabel?.text = event.time?.toString(withFormat: "yyyy-MM-dd")
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event: Event
        if Event.latestusedEvents.count > 0, indexPath.section == 0  {
            event = Event.latestusedEvents[indexPath.row]
        } else {
            event = Event.systemEvents[indexPath.row]
        }
        self.onResult?(event)
        self.navigationController?.popViewController(animated: true)
    }
    
}
