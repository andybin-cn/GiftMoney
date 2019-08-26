//
//  TradeFunctionButtonsView.swift
//  GiftMoney
//
//  Created by binea on 2019/8/26.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation


class TradeFunctionButtonsView: UIView {
    let stackView = UIStackView()
    var buttons = [UIButton]()
    
    init(items: [String], selectedIndex: [Int]) {
        super.init(frame: .zero)
        
        stackView.apply { (stackView) in
            stackView.axis = .vertical
            stackView.spacing = 10
            stackView.alignment = .center
            
            stackView.addTo(self) { (make) in
                make.edges.equalToSuperview()
            }
        }
        
        var rowStackView = UIStackView()
        items.enumerated().forEach { (index, item) in
            if index % 3 == 0 {
                rowStackView = UIStackView()
                rowStackView.apply { (stackView) in
                    stackView.axis = .horizontal
                    stackView.spacing = 15
                    stackView.alignment = .center
                    stackView.distribution = .fillEqually
                    self.stackView.addArrangedSubview(stackView)
                }
            }
            let button = UIButton()
            button.titleLabel?.numberOfLines = 2
            button.setTitleColor(UIColor.appGrayText, for: .normal)
            button.setTitleColor(UIColor.appSecondaryYellow, for: .selected)
            button.setBackgroundImage(UIColor.appSecondaryGray.toImage(), for: .normal)
            button.setBackgroundImage(UIColor.appMainRed.toImage(), for: .selected)
            button.setTitle(item, for: .normal)
            button.titleLabel?.font = UIFont.appFont(ofSize: 12)
            button.snp.makeConstraints { (make) in
                make.height.equalTo(34)
            }
            button.layer.cornerRadius = 17
            button.layer.masksToBounds = true
            button.tag = 100 + index
            button.isSelected = selectedIndex.contains(index)
            buttons.append(button)
            rowStackView.addArrangedSubview(button)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
