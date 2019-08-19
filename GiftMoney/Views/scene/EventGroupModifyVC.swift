//
//  EventGroupModifyVC.swift
//  GiftMoney
//
//  Created by binea on 2019/8/18.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class EventGroupModifyVC: BaseViewController {
    let scrollView = UIScrollView()
    
    let event: Event
    let trades: [Trade]
    
    let eventNameField = InputField(name: "eventName", labelString: "事件名称")
    let eventTimeField = DateInputField(name: "eventTime", labelString: "时间")
    
    init(event: Event, trades: [Trade]) {
        self.event = event
        self.trades = trades
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "事件详情"
        
        let deleteButton = UIBarButtonItem(title: "删除", style: UIBarButtonItem.Style.plain, target: self, action: #selector(onDeleteButtonTapped))
        self.navigationItem.rightBarButtonItems = [deleteButton]
        
        scrollView.apply { (scrollView) in
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.alwaysBounceVertical = true
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
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(onEventNameFieldtapped))
        eventNameField.addGestureRecognizer(tapGesture2)
        eventNameField.textfield.isUserInteractionEnabled = false
        eventNameField.addTo(scrollView) { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(20)
        }
        
        eventTimeField.addTo(scrollView) { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(eventNameField.snp.bottom).offset(15)
            make.bottom.equalTo(-40).priority(ConstraintPriority.low)
        }
        
        eventNameField.fieldValue = event.name
        eventTimeField.fieldValue = event.time ?? Date()
    }
    
    @objc func onDeleteButtonTapped() {
        
    }
    
    @objc func onEventNameFieldtapped() {
        let editorVC = EventEditeViewController(defaultValue: eventNameField.textfield.text) { [weak self] (event) in
            self?.eventNameField.fieldValue = event.name
            if let time = event.time {
                self?.eventTimeField.fieldValue = time
            }
        }
        self.navigationController?.pushViewController(editorVC, animated: true)
    }
    
    @objc func saveButtonTapped() {
        self.modifyAllEventForTrades()
    }
    
    func modifyAllEventForTrades() {
        do {
            let values = try self.validateForm()
            guard let eventName = values["eventName"] as? String, let eventTime = values["eventTime"] as? Date else {
                self.showTipsView(text: "保存失败，请填写所有表单信息")
                return
            }
            RealmManager.share.realm.beginWrite()
            trades.forEach { (trade) in
                trade.eventName = eventName
                trade.eventTime = eventTime
            }
            try RealmManager.share.realm.commitWrite()
            self.showTipsView(text: "保存成功")
        } catch let err as NSError {
            self.showTipsView(text: err.localizedDescription)
        }
    }
}
