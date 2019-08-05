//
//  SwitchInput.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/5.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa

class SwitchInput: UIView {
    let label = UILabel()
    let switcher = UISegmentedControl(items: ["送礼", "收礼"])
    var selectedIndex: Int {
        get { switcher.selectedSegmentIndex }
        set { switcher.selectedSegmentIndex = newValue }
    }
    
    init(labelString: String) {
        label.text = labelString
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    func setupViews() {
        layer.cornerRadius = 4
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.appGrayLine.cgColor
        
        label.apply { (label) in
            label.font = UIFont.appFont(ofSize: 12)
            label.textColor = UIColor.appGrayText
        }
        
        addSubview(label) { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(10)
        }
        
        switcher.setWidth(100, forSegmentAt: 0)
        switcher.setWidth(100, forSegmentAt: 1)
        switcher.selectedSegmentIndex = 0
        switcher.setBackgroundImage(UIColor.appMainYellow.toImage(), for: .selected, barMetrics: .default)
        switcher.setBackgroundImage(UIColor.appGrayBackground.toImage(), for: .normal, barMetrics: .default)
        
        addSubview(switcher) { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-15)
            make.height.equalTo(35)
        }
        self.snp.makeConstraints { (make) in
            make.height.equalTo(40)
        }
    }
    
}
