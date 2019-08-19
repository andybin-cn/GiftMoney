//
//  MineViewController.swift
//  GiftMoney
//
//  Created by binea on 2019/8/4.
//  Copyright © 2019 binea. All rights reserved.
//

import UIKit
import SnapKit

class MineViewController: BaseViewController {
    
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    
    let importiAndExport = MineTextRow(title: "Excel导入/导出", image: UIImage(named: "icons8-ms_excel"))
    let desc1 = MineDescriptionRow(text: "购买服务，永久解锁Excel导入/导出功能。")
    let backupData = MineTextRow(title: "备份数据到Apple Cloud", image: UIImage(named: "icons8-cloud_database"))
    let recoverData = MineTextRow(title: "从Apple Cloud恢复数据", image: UIImage(named: "icons8-data_recovery"))
    let desc2 = MineDescriptionRow(text: "购买服务，永久备份和恢复功能。此功能不会收集用户的任何数据，我们的App是离线的，没有任何后台服务，所有的数据都是保存在本地。备份服务会降数据保存至Apple的iCloud上，请放心使用！")
    
    let faceID = MineSwitchRow(title: "FaceID解锁", image: UIImage(named: "icons8-lock2"))
    let share = MineTextRow(title: "分享给好友", image: UIImage(named: "icons8-share"))
    let feedBack = MineTextRow(title: "意见反馈", image: UIImage(named: "icons8-feedback"))
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "普通用户（升级VIP体验更多功能）"
        
        scrollView.apply { (scrollView) in
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.alwaysBounceVertical = true
            scrollView.backgroundColor = UIColor.appGrayBackground
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
        
        stackView.apply { (stackView) in
            stackView.axis = .vertical
            stackView.alignment = .fill
            stackView.spacing = 0.5
            stackView.addTo(scrollView) { (make) in
                make.top.equalTo(20)
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview().offset(-40).priority(ConstraintPriority.low)
            }
        }
        stackView.addArrangedSubview(importiAndExport)
        stackView.addArrangedSubview(desc1)
        stackView.addArrangedSubview(backupData)
        stackView.addArrangedSubview(recoverData)
        stackView.addArrangedSubview(desc2)
        stackView.addArrangedSubview(faceID)
        stackView.addArrangedSubview(share)
        stackView.addArrangedSubview(feedBack)
    }
}
