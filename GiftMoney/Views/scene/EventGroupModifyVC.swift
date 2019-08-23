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
import Common

class EventGroupModifyVC: BaseViewController {
    let scrollView = UIScrollView()
    
    let event: Event
    let trades: [Trade]
    
    let tipsLabel = UILabel()
    let eventNameField = InputField(name: "eventName", labelString: "事件名称")
    let eventTimeField = DateInputField(name: "eventTime", labelString: "时间")
    let saveButton = UIButton()
    
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
        
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: "icons8-info")?.ui_renderImage(tintColor: UIColor.red)
        attachment.bounds = CGRect(x: 0, y: 0, width: 16, height: 16)
        let tipsString = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))
        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont.appFont(ofSize: 13)]
        tipsString.append(NSAttributedString(string: "【事件名称】和【事件时间】相同的视为同一个事件", attributes: attributes))
        tipsString.append(NSAttributedString(string: "\n1.修改事件会对此事件下的所有记录进行修改。", attributes: attributes))
        tipsString.append(NSAttributedString(string: "\n2.删除事件会删除此事件下的所有记录，请谨慎操作！", attributes: attributes))
        
        let tipsContianer = UIView().then { (contianer) in
            contianer.backgroundColor = UIColor.appGrayBackground
            tipsLabel.attributedText = tipsString
            tipsLabel.numberOfLines = 0

            
            contianer.addSubview(tipsLabel) { (make) in
                make.left.top.equalTo(15)
                make.right.bottom.equalTo(-15)
            }
            contianer.addTo(scrollView) { (make) in
                make.left.top.right.equalToSuperview()
            }
        }
        
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(onEventNameFieldtapped))
        eventNameField.addGestureRecognizer(tapGesture2)
        eventNameField.textfield.isUserInteractionEnabled = false
        eventNameField.addTo(scrollView) { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(tipsContianer.snp.bottom).offset(20)
        }
        
        eventTimeField.addTo(scrollView) { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(eventNameField.snp.bottom).offset(15)
        }
        
        saveButton.apply { (button) in
            button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
            button.layer.cornerRadius = 6
            button.layer.masksToBounds = true
            button.backgroundColor = UIColor.appMainYellow
            button.setTitle("保   存", for: .normal)
            button.addTo(scrollView) { (make) in
                make.left.equalTo(15)
                make.right.equalTo(-15)
                make.top.equalTo(eventTimeField.snp.bottom).offset(20)
                make.bottom.equalTo(-40).priority(ConstraintPriority.low)
            }
        }
        
        eventNameField.fieldValue = event.name
        eventTimeField.fieldValue = event.time ?? Date()
    }
    
    @objc func onDeleteButtonTapped() {
        self.showAlertView(title: "确定删除事件【\(event.name)】？", message: "一共包含\(trades.count)条记录", actions: [
            UIAlertAction.init(title: "取消", style: .cancel, handler: nil),
            UIAlertAction.init(title: "删除", style: .destructive, handler: { [weak self] (_) in
                self?.deleteAllEventForTrades()
            })
        ])
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
        guard MarketManager.shared.checkAuth(type: .modifyEvent, controller: self) else {
            return
        }
        self.modifyAllEventForTrades()
    }
    
    func deleteAllEventForTrades() {
        do {
            RealmManager.share.realm.beginWrite()
            RealmManager.share.realm.delete(trades)
            try RealmManager.share.realm.commitWrite()
            self.navigationController?.popViewController(animated: true)
            self.navigationController?.children.last?.showTipsView(text: "删除成功")
        } catch let error {
            self.showTipsView(text: error.localizedDescription)
        }
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
