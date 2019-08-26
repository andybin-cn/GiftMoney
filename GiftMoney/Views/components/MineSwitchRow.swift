//
//  MineSwitchRow.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/19.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class MineSwitchRow: UIView {
    let icon = UIImageView()
    let label = UILabel(textColor: UIColor.appDarkText, fontSize: 14)
    let switcher = UISwitch()
    
    init(title: String, image: UIImage?) {
        label.text = title
        icon.image = image
        super.init(frame: CGRect.zero)
        icon.addTo(self) { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
            make.width.height.equalTo(25)
        }
        
        label.addTo(self) { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(icon.snp.right).offset(8)
        }
        
        switcher.addTo(self) { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-15)
        }
        
        self.backgroundColor = .white
        self.snp.makeConstraints { (make) in
            make.height.equalTo(40)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
