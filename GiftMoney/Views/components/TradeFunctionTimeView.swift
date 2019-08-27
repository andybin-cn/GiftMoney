//
//  TradeFunctionTimeView.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/27.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import Common

class TradeFunctionTimeView: UIView {
    let startTimeField = TradeFunctionDateInputField(name: "eventTime", labelString: "开始时间")
    let endTimeField = TradeFunctionDateInputField(name: "eventTime", labelString: "结束时间")
    
    let stackView = UIStackView()
    
    var startTime: NSDate? {
        guard let date = startTimeField.date else {
            return nil
        }
        let daySecends = 60 * 60 * 24
        let minTime = Int(date.timeIntervalSince1970) / daySecends * daySecends
        return NSDate(timeIntervalSince1970: TimeInterval(minTime))
    }
    var endTime: NSDate? {
        guard let date = endTimeField.date else {
            return nil
        }
        let daySecends = 60 * 60 * 24
        let minTime = Int(date.timeIntervalSince1970) / daySecends * daySecends
        let maxtime = minTime + daySecends
        return NSDate(timeIntervalSince1970: TimeInterval(maxtime))
    }
    
    init() {
        super.init(frame: .zero)
        stackView.apply { (stackView) in
            stackView.axis = .horizontal
            stackView.alignment = .center
            stackView.spacing = 15
            stackView.distribution = .fillEqually
            stackView.addTo(self) { (make) in
                make.left.equalTo(15)
                make.right.equalTo(-15)
                make.top.bottom.equalToSuperview()
            }
        }
        UIView().apply { (spil) in
            spil.backgroundColor = UIColor.appGrayLine
            spil.addTo(stackView) { (make) in
                make.height.equalTo(1)
                make.width.equalTo(10)
                make.center.equalToSuperview()
            }
        }
        stackView.addArrangedSubview(startTimeField)
        stackView.addArrangedSubview(endTimeField)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



class TradeFunctionDateInputField: InputField {
    
    let datePicker = UIDatePicker()
    var date: Date? {
        didSet {
            if let date = date {
                datePicker.date = date
                textfield.text = date.toString(withFormat: "yyyy-MM-dd")
            } else {
                textfield.text = ""
            }
            textfieldChanged()
        }
    }
    
    override init(name: String, labelString: String) {
        super.init(name: name, labelString: labelString)
        
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(onDatePickerChanged(sender:)), for: UIControl.Event.valueChanged)
        textfield.inputView = datePicker
        
        textfieldChanged()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onDatePickerChanged(sender: UIDatePicker) {
        date = sender.date
    }
}
