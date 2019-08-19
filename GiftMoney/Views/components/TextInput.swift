
//
//  TextInput.swift
//  GiftMoney
//
//  Created by binea on 2019/8/18.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import UIKit

class TextInput: UIView, FormInput, UITextViewDelegate {
    
    var fieldName: String
    var fieldValue: FormValue {
        get {
            textfield.text ?? ""
        }
        set {
            textfield.text = newValue as? String
            textViewDidChange(textfield)
        }
    }
    
    func validateField() throws -> FormValue {
        return fieldValue
    }
    
    
    let label = UILabel()
    let textfield = UITextView()
    
    init(name: String, labelString: String) {
        self.fieldName = name
        super.init(frame: .zero)
        
        label.apply { (label) in
            label.font = UIFont.appFont(ofSize: 12)
            label.textColor = UIColor.appGrayText
            label.text = labelString
        }
        
        textfield.apply { (textfield) in
            textfield.isEditable = true
            textfield.font = UIFont.appFont(ofSize: 13)
            textfield.textColor = UIColor.appText
        }
        
        addSubview(textfield) { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(-4)
            make.top.equalTo(8)
        }
        
        addSubview(label) { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(10)
        }
        
        self.snp.makeConstraints { (make) in
            make.height.equalTo(60)
        }
        
        textfield.delegate = self
        
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
    
    func textViewDidChange(_ textView: UITextView) {
        let isEmpty = textfield.text?.isEmpty ?? true
        if isEmpty {
            labelPosition = .center
        } else {
            labelPosition = .top
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        labelPosition = .top
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        textViewDidChange(textView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
