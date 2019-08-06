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

class TradeItemRow: UIView {
    
    let switcher = UISegmentedControl(items: ["红包", "礼物"])
    let moneyField = InputField(labelString: "金额（元）")
    let giftField = UIView()
    let deleteButton = UIButton()
    weak var delegate: TradeItemRowDelegate?
    
    init(canDelete: Bool = false) {
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        layer.cornerRadius = 6
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.appGrayLine.cgColor
        
        switcher.selectedSegmentIndex = 0
        switcher.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        switcher.setBackgroundImage(UIColor.appMainYellow.toImage(), for: .selected, barMetrics: .default)
        switcher.setBackgroundImage(UIColor.appGrayBackground.toImage(), for: .normal, barMetrics: .default)
        switcher.addTarget(self, action: #selector(onWwitcherValueChanged), for: .valueChanged)
        
        addSubview(switcher) { (make) in
            make.left.top.bottom.equalToSuperview()
        }
        
        self.snp.makeConstraints { (make) in
            make.height.equalTo(40)
        }
        
        moneyField.apply { (field) in
            field.layer.borderWidth = 0
            field.addTo(self) { (make) in
                make.left.equalTo(switcher.snp.right).offset(20)
                make.right.equalTo(-10)
            }
        }
        
        giftField.apply { (giftField) in
            InputField(labelString: "礼物名称").apply { (field) in
                field.layer.borderWidth = 0
                field.addTo(giftField) { (make) in
                    make.left.top.equalToSuperview()
                    make.width.equalToSuperview().multipliedBy(0.5).offset(5)
                    make.bottom.equalToSuperview()
                }
            }
            InputField(labelString: "礼物数量(份/个)").apply { (field) in
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
        
        self.onWwitcherValueChanged()
    }
    
    @objc func onWwitcherValueChanged() {
        moneyField.isHidden = switcher.selectedSegmentIndex == 1
        giftField.isHidden = switcher.selectedSegmentIndex == 0
        
        self.endEditing(true)
    }
    
    @objc func onDeleteButtonTapped() {
        delegate?.onDeleteButtonTapped(row: self)
    }
    
}
