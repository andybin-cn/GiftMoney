//
//  TradeFunctionFilterView.swift
//  GiftMoney
//
//  Created by binea on 2019/8/26.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation


class TradeFunctionFilterView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    let leftTable = UITableView()
    
    let menus = ["事件", "关系", "时间", "金额"]
    
    init() {
        super.init(frame: .zero)
        leftTable.apply { (tableView) in
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.commonIdentifier)
            tableView.delegate = self
            tableView.dataSource = self
            
            tableView.addTo(self) { (make) in
                make.top.left.bottom.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.3)
            }
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return menus.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.commonIdentifier, for: indexPath)
//        cell.contentView.addSubview(<#T##view: UIView##UIView#>, layout: <#T##(ConstraintMaker) -> Void#>)
        return cell
    }

    
}
