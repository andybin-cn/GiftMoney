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

class SwitchInput: UIView, FormInput {
    let label = UILabel()
    let switcher = UISegmentedControl(items: ["送礼", "收礼"])
    var selectedIndex: Int {
        get { switcher.selectedSegmentIndex }
        set { switcher.selectedSegmentIndex = newValue }
    }
    
    var fieldName: String
    var fieldValue: FormValue {
        get {
            selectedIndex == 0 ? Trade.TradeType.outAccount.rawValue : Trade.TradeType.inAccount.rawValue
        }
        set {
            if let stringValue = newValue as? String {
                if stringValue == Trade.TradeType.inAccount.rawValue {
                    selectedIndex = 1
                } else {
                    selectedIndex = 0
                }
            }
        }
    }
    
    func validateField() throws -> FormValue {
        return fieldValue
    }
    
    init(name: String, labelString: String) {
        label.text = labelString
        fieldName = name
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fieldName = ""
        super.init(coder: coder)
        setupViews()
    }
    
    func setupViews() {
        layer.cornerRadius = 6
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
        switcher.layer.cornerRadius = 6
        switcher.layer.masksToBounds = true
        switcher.selectedSegmentIndex = 0
        switcher.tintColor = UIColor.appGrayBackground
        switcher.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
        switcher.setBackgroundImage(UIColor.appMainYellow.toImage(), for: .selected, barMetrics: .default)
        switcher.setBackgroundImage(UIColor.appGrayBackground.toImage(), for: .normal, barMetrics: .default)
        
        addSubview(switcher) { (make) in
            make.top.bottom.right.equalToSuperview()
        }
        self.snp.makeConstraints { (make) in
            make.height.equalTo(40)
        }
    }
    
}
