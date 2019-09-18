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
        return self.name
    }
}
extension String: TradeFunctionButtonItem {
    var title: String {
        return self
    }
}
extension Relationship: TradeFunctionButtonItem {
    var title: String {
        return self.name
    }
}

class TradeFunctionButtonsView: UIView {
    let stackView = UIStackView()
    var buttons = [UIButton]()
    let isMultiple: Bool
//    var selectedIndex: [Int]
    var items: [TradeFunctionButtonItem] {
        didSet {
            refreshItems()
        }
    }
    var selectedItems: [TradeFunctionButtonItem]
    
    init(items: [TradeFunctionButtonItem], selectedItems: [TradeFunctionButtonItem], isMultiple: Bool = true) {
        self.items = items
        self.isMultiple = isMultiple
        self.selectedItems = selectedItems
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
        refreshItems()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refreshItems() {
        stackView.subviews.forEach { (subview) in
            stackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
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
            button.isSelected = self.selectedItems.contains(where: { $0.title == item.title })
            buttons.append(button)
            rowStackView.addArrangedSubview(button)
        }
    }
    
    
    @objc func onButtonItemTapped(sender: UIButton) {
        let index = sender.tag
        if index < 0 || index >= self.items.count {
            sender.isSelected = !sender.isSelected
            return
        }
        if isMultiple {
            sender.isSelected = !sender.isSelected
            self.selectedItems = buttons.filter{ $0.isSelected }.map({ (button) -> TradeFunctionButtonItem in
                let index = button.tag
                return self.items[index]
            })
        } else {
            let currentItem = self.items[index]
            buttons.forEach { (button) in
                button.isSelected = false
            }
            if let oldItem = self.selectedItems.first, oldItem.title == currentItem.title {
                self.selectedItems = []
            } else {
                self.selectedItems = [currentItem]
                sender.isSelected = true
            }
        }
    }
    
    func resetWith(items: [TradeFunctionButtonItem], selectedItems: [TradeFunctionButtonItem] = []) {
        self.items = items
        self.selectedItems = []
        refreshItems()
    }
    
}
