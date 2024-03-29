//
//  TradeItemRow.swift
//  GiftMoney
//
//  Created by binea on 2019/8/5.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import UIKit

protocol TradeItemRowDelegate: class {
    func onDeleteButtonTapped(row: TradeItemRow)
}

class TradeItemRow: UIView, FormInput {
    var fieldName: String
    var valueSrtuct: FormInputValueSrtuct { return  .array }
    
    var tradeItemType: TradeItem.ItemType {
        get {
            return switcher.selectedSegmentIndex == 0 ? TradeItem.ItemType.money : TradeItem.ItemType.gift
        }
        set {
            switcher.selectedSegmentIndex = newValue == .money ? 0 : 1
        }
    }
    var tradeItemName: String {
        return switcher.selectedSegmentIndex == 0 ? "人民币" : giftNameField.textfield.text ?? ""
    }
    var tradeItemValue: String {
        return switcher.selectedSegmentIndex == 0 ? moneyField.textfield.text ?? "" : giftValueField.textfield.text ?? ""
    }
    
    var fieldValue: FormValue {
        get {
            return [
                "type": tradeItemType.rawValue,
                "name": tradeItemName,
                "value": tradeItemValue,
            ] as FormValue
        }
        set {
            
        }
    }
    
    func validateField() throws -> FormValue {
        return fieldValue
    }
    
    
    let switcher = UISegmentedControl(items: ["红包", "礼物"])
    let moneyField = InputField(name: "name", labelString: "金额（元）")
    let giftField = UIView()
    let giftNameField = InputField(name: "gitfName", labelString: "礼物名称")
    let giftValueField = InputField(name: "gitfValue", labelString: "礼物数量(份/个)")
    let deleteButton = UIButton()
    weak var delegate: TradeItemRowDelegate?
    
    init(name: String, tradeItem: TradeItem? = nil,canDelete: Bool = false) {
        fieldName = name
        super.init(frame: .zero)
        setupViews()
        if canDelete {
            deleteButton.apply { (button) in
                button.setImage(UIImage.init(named: "icons8-delete_sign"), for: .normal)
                button.addTarget(self, action: #selector(onDeleteButtonTapped), for: .touchUpInside)
                button.addTo(self) { (make) in
                    make.right.top.equalToSuperview()
                    make.width.height.equalTo(18)
                }
            }
        }
        if let tradeItem = tradeItem, let type = tradeItem.type {
            if type == .money {
                switcher.selectedSegmentIndex = 0
                moneyField.fieldValue = tradeItem.value
            } else if type == .gift {
                switcher.selectedSegmentIndex = 1
                giftNameField.fieldValue = tradeItem.name
                giftValueField.fieldValue = tradeItem.value
            }
            onSwitcherValueChanged()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        layer.cornerRadius = 6
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.appGrayLine.cgColor
        self.clipsToBounds = true
        
        switcher.layer.cornerRadius = 6
        switcher.layer.masksToBounds = true
        switcher.selectedSegmentIndex = 0
        switcher.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        switcher.tintColor = UIColor.appSecondaryRed
        switcher.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.appGrayText, NSAttributedString.Key.font: UIFont.appFont(ofSize: 11)], for: .normal)
        switcher.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.appSecondaryYellow, NSAttributedString.Key.font: UIFont.appBoldFont(ofSize: 15)], for: .selected)
        switcher.setBackgroundImage(UIColor.appSecondaryRed.toImage(), for: .selected, barMetrics: .default)
        switcher.setBackgroundImage(UIColor.appSecondaryGray.toImage(), for: .normal, barMetrics: .default)
        
        switcher.addTarget(self, action: #selector(onSwitcherValueChanged), for: .valueChanged)
        
        addSubview(switcher) { (make) in
            make.left.top.bottom.equalToSuperview()
        }
        
        self.snp.makeConstraints { (make) in
            make.height.equalTo(40)
        }
        
        moneyField.apply { (field) in
            field.textfield.keyboardType = .numberPad
            field.layer.borderWidth = 0
            field.addTo(self) { (make) in
                make.left.equalTo(switcher.snp.right).offset(20)
                make.right.equalTo(-10)
            }
        }
        
        giftField.apply { (giftField) in
            giftNameField.apply { (field) in
                field.layer.borderWidth = 0
                field.addTo(giftField) { (make) in
                    make.left.top.equalToSuperview()
                    make.width.equalToSuperview().multipliedBy(0.5).offset(5)
                    make.bottom.equalToSuperview()
                }
            }
            giftValueField.apply { (field) in
                field.textfield.keyboardType = .numberPad
                field.layer.borderWidth = 0
                field.addTo(giftField) { (make) in
                    make.right.top.equalToSuperview()
                    make.width.equalToSuperview().multipliedBy(0.5).offset(5)
                }
            }
            giftField.addTo(self) { (make) in
                make.left.equalTo(switcher.snp.right).offset(20)
                make.right.equalTo(-10)
            }
        }
        
        self.onSwitcherValueChanged()
    }
    
    @objc func onSwitcherValueChanged() {
        moneyField.isHidden = switcher.selectedSegmentIndex == 1
        giftField.isHidden = switcher.selectedSegmentIndex == 0
        
        self.endEditing(true)
    }
    
    @objc func onDeleteButtonTapped() {
        delegate?.onDeleteButtonTapped(row: self)
    }
    
}
