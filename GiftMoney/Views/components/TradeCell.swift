//
//  TradeCell.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/7.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import UIKit

class TradeCell: UITableViewCell {
    let iconLabel = UILabel()
    let nameLabel = UILabel()
    let eventLabel = UILabel()
    let timeLabel = UILabel()
    let gitfLabel = UILabel()
    let moneyLabel = UILabel()
    
    var trade: Trade?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    func setupSubviews() {
        accessoryType = .disclosureIndicator
        
        iconLabel.apply { (label) in
            label.font = UIFont.appBoldFont(ofSize: 25)
            label.textColor = .white
            label.layer.cornerRadius = 20
            label.clipsToBounds = true
            label.layer.borderWidth = 1
            label.textAlignment = .center
            label.backgroundColor = .appSecondaryYellow
            label.layer.borderColor = UIColor.appMainRed.cgColor
            
            label.addTo(contentView) { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(15)
                make.height.width.equalTo(40)
                make.height.lessThanOrEqualToSuperview().inset(20)
            }
        }
        
        nameLabel.apply { (label) in
            label.font = UIFont.appFont(ofSize: 13)
            label.textColor = .appDarkText
            
            label.addTo(contentView) { (make) in
                make.top.greaterThanOrEqualToSuperview().offset(8)
                make.left.equalTo(iconLabel.snp.right).offset(10)
            }
        }
        eventLabel.apply { (label) in
            label.font = UIFont.appFont(ofSize: 13)
            label.textColor = .appGrayText
            
            label.addTo(contentView) { (make) in
                make.top.equalTo(nameLabel.snp.bottom).offset(5)
                make.left.equalTo(nameLabel.snp.left)
            }
        }
        timeLabel.apply { (label) in
            label.font = UIFont.appFont(ofSize: 11)
            label.textColor = .appGrayText
            
            label.addTo(contentView) { (make) in
                make.top.equalTo(eventLabel.snp.bottom).offset(5)
                make.left.equalTo(nameLabel.snp.left)
                make.bottom.lessThanOrEqualToSuperview().inset(8)
            }
        }
        let stackView = UIStackView().then { (stackView) in
            stackView.axis = .vertical
            stackView.spacing = 6
            stackView.alignment = .trailing
            stackView.addTo(contentView) { (make) in
                make.centerY.equalToSuperview()
                make.right.equalTo(-40)
            }
        }
        gitfLabel.apply { (label) in
            label.font = UIFont.appFont(ofSize: 15)
            label.textColor = .appSecondaryYellow
        }
        moneyLabel.apply { (label) in
            label.font = UIFont.appFont(ofSize: 15)
            label.textColor = .appSecondaryYellow
        }
        stackView.addArrangedSubview(moneyLabel)
        stackView.addArrangedSubview(gitfLabel)
    }
    
    func configerUI(trade: Trade) {
        self.trade = trade
        guard let type = trade.type else {
            return
        }
        if type == .inAccount {
            iconLabel.text = "收"
            iconLabel.backgroundColor = UIColor.appSecondaryYellow
            iconLabel.layer.borderColor = UIColor.appMainRed.cgColor
            iconLabel.textColor = .appMainRed
        } else {
            iconLabel.backgroundColor = UIColor.appMainRed
            iconLabel.layer.borderColor = UIColor.appSecondaryYellow.cgColor
            iconLabel.text = "支"
            iconLabel.textColor = .white
        }
        
        nameLabel.text = trade.name
        eventLabel.text = trade.eventName
        timeLabel.text = trade.eventTime.toString(withFormat: "yyyy-MM-dd")
        gitfLabel.text = "礼物共 \(trade.giftCount)份"
        moneyLabel.text = String.init(format: "红包共 ¥%0.0f元", trade.totalMoney)
        
    }
}
