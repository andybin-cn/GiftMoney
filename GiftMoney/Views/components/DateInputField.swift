//
//  DateInputField.swift
//  GiftMoney
//
//  Created by binea on 2019/8/7.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import UIKit
import Common

class DateInputField: InputField {
    
    var date: Date
    override var fieldValue: FormValue {
        get {
            date
        }
        set {
            guard let date = newValue as? Date else {
                return
            }
            self.date = date
            textfield.text = date.toString(withFormat: "yyyy-MM-dd")
            textfieldChanged()
        }
    }
    
    override init(name: String, labelString: String) {
        date = Date()
        super.init(name: name, labelString: labelString)
        
        let datePicker = UIDatePicker()
        datePicker.date = date
        datePicker.datePickerMode = .date
//        datePicker.minuteInterval = 30
        datePicker.addTarget(self, action: #selector(onDatePickerChanged(sender:)), for: UIControl.Event.valueChanged)
        
        textfield.inputView = datePicker
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onDatePickerChanged(sender: UIDatePicker) {
        fieldValue = sender.date
    }
}
