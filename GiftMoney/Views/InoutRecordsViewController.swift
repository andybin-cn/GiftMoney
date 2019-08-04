//
//  InoutRecordsViewController.swift
//  GiftMoney
//
//  Created by binea on 2019/8/4.
//  Copyright © 2019 binea. All rights reserved.
//

import UIKit

class InoutRecordsViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "收支记录"
        
        
        let addRecordButton = UIBarButtonItem(title: "新增", style: UIBarButtonItem.Style.plain, target: self, action: #selector(addRecordButtonTapped))
        self.navigationItem.rightBarButtonItems = [addRecordButton]
        
    }
    
    @objc func addRecordButtonTapped() {
        
        navigationController?.pushViewController(AddTradeViewController(), animated: true)
    }
}
