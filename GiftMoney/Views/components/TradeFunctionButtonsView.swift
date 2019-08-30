//
//  TradeFunctionButtonsView.swift
//  GiftMoney
//
//  Created by binea on 2019/8/26.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation


protocol TradeFunctionButtonItem {
    var title: String { get }
}

extension Event: TradeFunctionButtonItem {
    var title: String {
        self.name
    }
}
extension String: TradeFunctionButtonItem {
    var title: String {
        self
    }
}
extension Relationship: TradeFunctionButtonItem {
    var title: String {
        self.name
    }
}

class TradeFunctionButtonsView: UIView {
    let stackView = UIStackView()
    var buttons = [UIButton]()
    let isMultiple: Bool
    var selectedIndex: [Int]
    let items: [TradeFunctionButtonItem]
    var selectedItems: [TradeFunctionButtonItem] {
        selectedIndex.map { (index) -> TradeFunctionButtonItem? in
            index < items.count ? items[index] : nil
        }.filter { $0 != nil }.map { $0! }
    }
    
    init(items: [TradeFunctionButtonItem], selectedIndex: [Int], isMultiple: Bool = true) {
        self.items = items
        self.isMultiple = isMultiple
        self.selectedIndex = selectedIndex
        super.init(frame: .zero)
        
        stackView.apply { (stackView) in
            stackView.axis = .vertical
            stackView.spacing = 10
            stackView.alignment = .leading
            
            stackView.addTo(self) { (make) in
                make.left.equalTo(15)
                make.right.equalTo(-15)
                make.top.bottom.equalToSuperview()
            }
        }
        
        var rowStackView = UIStackView()
        let itemWidth = (ScreenHelp.windowWidth - 15 * 4) / 3
        items.enumerated().forEach { (index, item) in
            if index % 3 == 0 {
                rowStackView = UIStackView()
                rowStackView.apply { (stackView) in
                    stackView.axis = .horizontal
                    stackView.spacing = 15
                    stackView.alignment = .center
                    self.stackView.addArrangedSubview(stackView)
                }
            }
            let button = UIButton()
            button.titleLabel?.numberOfLines = 2
            button.titleLabel?.lineBreakMode = .byCharWrapping
            button.titleLabel?.textAlignment = .center
            button.setTitleColor(UIColor.appGrayText, for: .normal)
            button.setTitleColor(UIColor.appSecondaryYellow, for: .selected)
            button.setBackgroundImage(UIColor.appSecondaryGray.toImage(), for: .normal)
            button.setBackgroundImage(UIColor.appMainRed.toImage(), for: .selected)
            button.setTitle(item.title, for: .normal)
            button.titleLabel?.font = UIFont.appFont(ofSize: 12)
            button.addTarget(self, action: #selector(onButtonItemTapped(sender:)), for: .touchUpInside)
            button.snp.makeConstraints { (make) in
                make.height.equalTo(34)
                make.width.equalTo(itemWidth)
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
    
    
    @objc func onButtonItemTapped(sender: UIButton) {
        if isMultiple {
            sender.isSelected = !sender.isSelected
            self.selectedIndex = buttons.filter{ $0.isSelected }.map { $0.tag - 100 }
        } else {
            let oldSelected = self.selectedIndex.contains(sender.tag - 100)
            buttons.forEach { (button) in
                button.isSelected = false
            }
            if oldSelected {
                self.selectedIndex = []
            } else {
                self.selectedIndex = [sender.tag - 100]
                sender.isSelected = true
            }
        }
    }
    
}