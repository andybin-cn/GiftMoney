//
//  AddTradeViewController.swift
//  GiftMoney
//
//  Created by binea on 2019/8/4.
//  Copyright © 2019 binea. All rights reserved.
//

import UIKit

class AddTradeViewController: BaseViewController {

    let scrollView = UIScrollView()
    
    let nameField = InputField(labelString: "姓名")
    let relationshipField = InputField(labelString: "关系")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "新增记录"
        
        scrollView.apply { (scrollView) in
            scrollView.showsHorizontalScrollIndicator = false
            
            scrollView.addTo(self.view) { (make) in
                make.edges.equalToSuperview()
            }
            
            UIView().apply { (widthView) in
                widthView.addTo(scrollView) { (make) in
                    make.left.right.top.equalToSuperview()
                    make.height.equalTo(0)
                    make.width.equalTo(self.view)
                }
            }
        }
        
        
        nameField.addTo(scrollView) { (make) in
            make.left.equalTo(15)
            make.top.equalTo(20)
            make.width.equalTo(self.view.snp.width).multipliedBy(0.5).offset(-22.5)
        }
        
        relationshipField.addTo(scrollView) { (make) in
            make.right.equalTo(-15)
            make.centerY.equalTo(nameField)
            make.width.equalTo(nameField)
        }
    }

}
