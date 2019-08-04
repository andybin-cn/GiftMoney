//
//  InoutRecordsViewController.swift
//  GiftMoney
//
//  Created by binea on 2019/8/4.
//  Copyright © 2019 binea. All rights reserved.
//

import UIKit
import Common

class InoutRecordsViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "收支记录"
        
        let addRecordButton = UIBarButtonItem(title: "新增", style: UIBarButtonItem.Style.plain, target: self, action: #selector(addRecordButtonTapped))
        self.navigationItem.rightBarButtonItems = [addRecordButton]

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
}
