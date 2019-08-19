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
    var event: Event? {
        didSet {
            textLabel?.text = event?.name
            detailTextLabel?.text = event?.time?.toString(withFormat: "yyyy-MM-dd")
        }
    }
//    let detailButton = UIButton()
//    weak var delegate: EventGroupCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.accessoryType = .detailButton
        
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
