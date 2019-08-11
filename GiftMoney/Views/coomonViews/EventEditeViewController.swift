//
//  EventEditeViewController.swift
//  GiftMoney
//
//  Created by binea on 2019/8/11.
//  Copyright © 2019 binea. All rights reserved.
//

import UIKit

class EventEditeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableView = UITableView()
    let inputField = UITextField()
    
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
            tableView.register(TradeCell.self, forCellReuseIdentifier: UITableViewCell.commonIdentifier)
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
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: UITableViewCell.commonIdentifier, for: indexPath)
    }
    
}
