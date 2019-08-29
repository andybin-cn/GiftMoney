//
//  EventsGroupCell.swift
//  GiftMoney
//
//  Created by binea on 2019/8/18.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import UIKit

class EventGroupCell: UITableViewCell {
    let eventLabel = UILabel()
    let timeLabel = UILabel()
    
    let tradeCountLabel = UILabel()
    let gitfLabel = UILabel()
    let moneyLabel = UILabel()
    
    var event: Event? {
        didSet {
            eventLabel.text = event?.name
            timeLabel.text = event?.time?.toString(withFormat: "yyyy-MM-dd")
            if let event = event {
                gitfLabel.text = "礼物共\(event.giftCount)件"
                tradeCountLabel.text = "共 \(event.tradeCount) 条记录"
                moneyLabel.text = String.init(format: "红包共 ¥%0.0f元", event.totalMoney)
            }
            
        }
    }
//    let detailButton = UIButton()
//    weak var delegate: EventGroupCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.accessoryType = .detailButton
        
        eventLabel.apply { (label) in
            label.font = UIFont.appFont(ofSize: 13)
            label.textColor = .appDarkText
        }
        timeLabel.apply { (label) in
            label.font = UIFont.appFont(ofSize: 11)
            label.textColor = .appGrayText
        }
        tradeCountLabel.apply { (label) in
            label.font = UIFont.appFont(ofSize: 13)
            label.textColor = .appGrayText
        }
        let stackView1 = UIStackView().then { (stackView) in
            stackView.axis = .vertical
            stackView.spacing = 6
            stackView.alignment = .leading
            stackView.addTo(contentView) { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(15)
                make.top.greaterThanOrEqualTo(10)
                make.bottom.lessThanOrEqualTo(-10)
            }
        }
        stackView1.addArrangedSubview(eventLabel)
        stackView1.addArrangedSubview(tradeCountLabel)
        stackView1.addArrangedSubview(timeLabel)
        
        
        let stackView2 = UIStackView().then { (stackView) in
            stackView.axis = .vertical
            stackView.spacing = 6
            stackView.alignment = .trailing
            stackView.addTo(contentView) { (make) in
                make.centerY.equalToSuperview()
                make.right.equalTo(-15)
                make.top.greaterThanOrEqualTo(10)
                make.bottom.lessThanOrEqualTo(-10)
            }
        }
        gitfLabel.apply { (label) in
            label.font = UIFont.appFont(ofSize: 13)
            label.textColor = .appSecondaryYellow
        }
        moneyLabel.apply { (label) in
            label.font = UIFont.appFont(ofSize: 16)
            label.textColor = .appSecondaryYellow
        }
        stackView2.addArrangedSubview(moneyLabel)
        stackView2.addArrangedSubview(gitfLabel)
        
//        detailButton.apply { (button) in
//            button.addTarget(self, action: #selector(onDetailButtontapped), for: .touchUpInside)
//            button.addTo(contentView) { (make) in
//                make.left.right.bottom.equalToSuperview()
//                make.width.equalTo(50)
//            }
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    @objc func onDetailButtontapped() {
//        guard let event = event else {
//            return
//        }
//        delegate?.eventGroupCell(cell: self, onDetailButtontapped: event)
//    }
    
}
