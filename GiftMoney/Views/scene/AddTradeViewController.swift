//
//  AddTradeViewController.swift
//  GiftMoney
//
//  Created by binea on 2019/8/4.
//  Copyright © 2019 binea. All rights reserved.
//

import UIKit
import Common
import ObjectMapper
import Realm

class AddTradeViewController: BaseViewController, TradeItemRowDelegate {

    let scrollView = UIScrollView()
    
    let typeSwitch = SwitchInput(name:"type", labelString: "类型：")
    let nameField = InputField(name: "name", labelString: "姓名")
    let relationshipField = InputField(name: "relationship", labelString: "关系")
    let eventNameField = InputField(name: "eventName", labelString: "事件名称")
    let eventTimeField = DateInputField(name: "eventTime", labelString: "时间")
    let itemsStackView = UIStackView()
    let addItemButton = UIButton()
    var trade: Trade?
    
    init(trade: Trade? = nil) {
        self.trade = trade
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "新增记录"
        let saveButton = UIBarButtonItem(title: "保存", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButtonTapped))
        self.navigationItem.rightBarButtonItems = [saveButton]
        
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
        
        typeSwitch.addTo(scrollView) { (make) in
            make.right.equalTo(-15)
            make.left.equalTo(15)
            make.top.equalTo(20)
        }
        
        nameField.addTo(scrollView) { (make) in
            make.left.equalTo(15)
            make.top.equalTo(typeSwitch.snp.bottom).offset(15)
            make.width.equalTo(self.view.snp.width).multipliedBy(0.5).offset(-22.5)
        }
        
        relationshipField.addTo(scrollView) { (make) in
            make.right.equalTo(-15)
            make.centerY.equalTo(nameField)
            make.width.equalTo(nameField)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(oneEventNameFieldtapped))
        eventNameField.addGestureRecognizer(tapGesture)
        eventNameField.textfield.isUserInteractionEnabled = false
        eventNameField.addTo(scrollView) { (make) in
            make.left.width.equalTo(nameField)
            make.top.equalTo(nameField.snp.bottom).offset(15)
        }
        
        eventTimeField.addTo(scrollView) { (make) in
            make.left.width.equalTo(relationshipField)
            make.top.equalTo(relationshipField.snp.bottom).offset(15)
        }
        
//        FormWrapper(name: "tradeItems")
        
        itemsStackView.apply { (stackView) in
            stackView.axis = .vertical
            stackView.alignment = .fill
            stackView.spacing = 15
            stackView.addTo(scrollView) { (make) in
                make.top.equalTo(eventNameField.snp.bottom).offset(15)
                make.left.equalTo(15)
                make.right.equalTo(-15)
            }
        }
        itemsStackView.addArrangedSubview(TradeItemRow(name: "tradeItems", canDelete: false))
        
        addItemButton.apply { (button) in
            button.setImage(UIImage.init(named: "icons8-add"), for: .normal)
            button.setTitle("增加一项", for: .normal)
            button.setTitleColor(.appGrayText, for: .normal)
            button.titleLabel?.font = .appFont(ofSize: 13)
            button.layer.borderWidth = 0.5
            button.layer.borderColor = UIColor.appGrayLine.cgColor
            button.layer.cornerRadius = 6
            button.addTarget(self, action: #selector(onAddItemButtonTapped), for: .touchUpInside)
            button.snp.makeConstraints { (make) in
                make.height.equalTo(40)
            }
        }
        itemsStackView.addArrangedSubview(addItemButton)
        
        fillInFormValues()
    }
    func fillInFormValues() {
        guard let trade = self.trade else {
            return
        }
        if let tradeType = trade.type {
            typeSwitch.fieldValue = tradeType.rawValue
        } else {
            typeSwitch.selectedIndex = 0
        }
        nameField.fieldValue = trade.name
        relationshipField.fieldValue = trade.relationship
        eventNameField.fieldValue = trade.eventName
        eventTimeField.fieldValue = trade.eventTime
        
        if trade.tradeItems.count > 0 {
            itemsStackView.arrangedSubviews.forEach { (arrangedView) in
                if arrangedView is TradeItemRow {
                    itemsStackView.removeArrangedSubview(arrangedView)
                    arrangedView.removeFromSuperview()
                }
            }
            trade.tradeItems.enumerated().forEach { (index, tradeItem) in
                itemsStackView.addArrangedSubview(TradeItemRow(name: "tradeItems",tradeItem: tradeItem, canDelete: index != 0))
            }
        }
    }
    
    @objc func onAddItemButtonTapped() {
        let newRow = TradeItemRow(name: "tradeItems", tradeItem: nil, canDelete: true)
        newRow.delegate = self
        itemsStackView.insertArrangedSubview(newRow, at: itemsStackView.arrangedSubviews.count-1)
    }
    
    @objc func saveButtonTapped() {
        do {
            let values = try self.validateForm()
            
            guard let newTrade = Trade.init(JSON: values) else {
                self.showTipsView(text: "数据保存失败，请返回后重试")
                return
            }
            RealmManager.share.realm.beginWrite()
            if let oldTrade = self.trade {
                newTrade.id = oldTrade.id
                RealmManager.share.realm.delete(oldTrade.tradeItems)
                RealmManager.share.realm.delete(oldTrade.tradeMedias)
            }
            RealmManager.share.realm.add(newTrade, update: .all)
            try RealmManager.share.realm.commitWrite()
            trade = newTrade
            self.navigationController?.popViewController(animated: true)
        } catch let err as NSError {
            self.showTipsView(text: err.localizedDescription)
        }
    }
    
    @objc func oneEventNameFieldtapped() {
        let editorVC = EventEditeViewController { [weak self] (event) in
            self?.eventNameField.fieldValue = event.name
            if let time = event.time {
                self?.eventTimeField.fieldValue = time
            }
        }
        self.navigationController?.pushViewController(editorVC, animated: true)
    }
    
    
    // MARK: - TradeItemRowDelegate
    func onDeleteButtonTapped(row: TradeItemRow) {
        itemsStackView.removeArrangedSubview(row)
        row.removeFromSuperview()
    }
    
}
