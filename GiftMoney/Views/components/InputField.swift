//
//  InputField.swift
//  GiftMoney
//
//  Created by binea on 2019/8/4.
//  Copyright © 2019 binea. All rights reserved.
//

import UIKit
import Common

class InputField: UIView {
    
    let label = UILabel()
    let textfield = UITextField()
    
    init(labelString: String) {
        super.init(frame: .zero)
        
        label.apply { (label) in
            label.font = UIFont.appFont(ofSize: 12)
            label.textColor = UIColor.appGrayText
            label.text = labelString
        }
        
        textfield.apply { (textfield) in
            textfield.font = UIFont.appFont(ofSize: 13)
        }
        
        addSubview(label) { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(10)
        }
        
        addSubview(textfield) { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(-4)
        }
        
        self.snp.makeConstraints { (make) in
            make.height.equalTo(40)
        }
        
        
        textfield.addTarget(self, action: #selector(textfieldChanged), for: UIControl.Event.allEvents)
        
        layer.cornerRadius = 4
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.appGrayLine.cgColor
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onSelfTaped))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func onSelfTaped() {
        textfield.becomeFirstResponder()
    }
    
    enum LabelPosition {
        case top
        case center
    }
    
    var labelPosition: LabelPosition = .center {
        didSet {
            if oldValue != labelPosition {
                executeLabelAnimate()
            }
        }
    }
    
    func executeLabelAnimate() {
        if labelPosition == .top {
            self.label.snp.remakeConstraints { (make) in
                make.top.equalTo(2)
                make.left.equalTo(10)
            }
            UIView.animate(withDuration: 0.2) {
                self.label.font = UIFont.appFont(ofSize: 10)
                self.layoutIfNeeded()
            }
        } else {
            self.label.snp.remakeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(10)
            }
            UIView.animate(withDuration: 0.2) {
                self.label.font = UIFont.appFont(ofSize: 12)
                self.layoutIfNeeded()
            }
        }
    }
    
    
    @objc func textfieldChanged() {
        let isEmpty = textfield.text?.isEmpty ?? true
        if textfield.isEditing || !isEmpty {
            labelPosition = .top
        } else {
            labelPosition = .center
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
