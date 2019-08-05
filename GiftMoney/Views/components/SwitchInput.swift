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
    let leftButton = UIButton()
    let rightButton = UIButton()
    
    private(set) var selectedIndex = 0 {
        didSet {
            if oldValue != selectedIndex {
                executeLabelAnimate()
            }
        }
    }
    
    init(labelString: String, left: String, right: String) {
        label.text = labelString
        leftButton.setTitle(left, for: .normal)
        rightButton.setTitle(right, for: .normal)
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
        
        let stackView = UIStackView()
        stackView.apply { (stackView) in
            stackView.axis = .horizontal
        }
        
        stackView.addArrangedSubview(leftButton)
        stackView.addArrangedSubview(rightButton)
        layoutButtons()
        
        addSubview(stackView) { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-15)
            make.height.equalTo(35)
            make.height.lessThanOrEqualToSuperview()
        }
        
        _ = leftButton.rx.controlEvent(UIControl.Event.touchUpInside).asObservable().subscribe(onNext: { [weak self] () in
            self?.selectedIndex = 0
        })
        
        _ = rightButton.rx.controlEvent(UIControl.Event.touchUpInside).asObservable().subscribe(onNext: { [weak self] () in
            self?.selectedIndex = 1
        })
    }
    
    func notSelectedStyle(button: UIButton) {
        button.backgroundColor = UIColor.appGrayBackground
        button.titleLabel?.textColor = UIColor.appGrayText
        button.snp.remakeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalToSuperview().multipliedBy(0.6)
        }
    }
    func selectedStyle(button: UIButton) {
        button.backgroundColor = UIColor.appTextBlue
        button.titleLabel?.textColor = UIColor.appText
        button.snp.remakeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalToSuperview().multipliedBy(0.6)
        }
    }
    
    func layoutButtons() {
        if selectedIndex == 0 {
            selectedStyle(button: leftButton)
            notSelectedStyle(button: rightButton)
        } else {
            selectedStyle(button: rightButton)
            notSelectedStyle(button: leftButton)
        }
    }
    
    func executeLabelAnimate() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 8, options: [], animations: {
            self.layoutButtons()
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
}
