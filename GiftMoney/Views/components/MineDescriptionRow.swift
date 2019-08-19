//
//  MineDescriptionRow.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/19.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import UIKit

class MineDescriptionRow: UIView {
    let textLabel = UILabel(textColor: UIColor.appText, font: UIFont.appFont(ofSize: 10))
    init(text: String) {
        super.init(frame: .zero)
        textLabel.text = text
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byCharWrapping
        textLabel.textAlignment = .left
        textLabel.addTo(self) { (make) in
            make.left.equalTo(15)
            make.top.equalTo(8)
            make.bottom.equalTo(-8)
            make.right.equalTo(-15)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
