//
//  InputField.swift
//  GiftMoney
//
//  Created by binea on 2019/8/4.
//  Copyright © 2019 binea. All rights reserved.
//

import UIKit
import Common

class InputField: UIView, FormInput, UITextFieldDelegate {
    
    var fieldName: String
    var fieldValue: FormValue {
        get {
            return textfield.text ?? ""
        }
        set {
            textfield.text = newValue as? String
            textfieldChanged()
        }
    }
    
    func validateField() throws -> FormValue {
        return fieldValue
    }
    
    
    let label = UILabel()
    let textfield = UITextField()
    
    let maxLength: Int
    init(name: String, labelString: String, maxLength: Int = 10) {
        self.maxLength = maxLength
        self.fieldName = name
        super.init(frame: .zero)
        
        label.apply { (label) in
            label.font = UIFont.appFont(ofSize: 12)
            label.textColor = UIColor.appGrayText
            label.text = labelString
        }
        
        textfield.apply { (textfield) in
            textfield.delegate = self
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
        
        layer.cornerRadius = 6
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
        let isEmpty = textfield.text?.isEmptyString ?? true
        if textfield.isEditing || !isEmpty {
            labelPosition = .top
        } else {
            labelPosition = .center
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldString: NSString = (textField.text as NSString?) ?? "" as NSString
        let newString = oldString.replacingCharacters(in: range, with: string)
        return newString.count <= maxLength
    }
    
}
