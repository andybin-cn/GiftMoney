//
//  TradeFunctionFilterView.swift
//  GiftMoney
//
//  Created by binea on 2019/8/26.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation

class FilterOption {
    var events = [Event]()
    var relations = [Relationship]()
    var startTime: Date?
    var endTime: Date?
    var minAmount: Float?
    var maxAmount: Float?
}


class TradeFunctionFilterView: UIView {
    
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    
    init() {
        super.init(frame: .zero)
        
        let eventGroup = TradeFunctionContainerView(title: "事件类型", body: TradeFunctionButtonsView(items: Event.allEventNames, selectedIndex: [2]))
        let relationGroup = TradeFunctionContainerView(title: "关系", body: TradeFunctionButtonsView(items: Relationship.latestusedRelationships, selectedIndex: [1]))
        self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        scrollView.apply { (scrollView) in
            scrollView.alwaysBounceVertical = true
            scrollView.alwaysBounceHorizontal = false
            scrollView.backgroundColor = UIColor.appGrayBackground
            scrollView.addTo(self) { (make) in
                make.left.top.right.equalToSuperview()
                make.height.equalTo(ScreenHelp.windoHeight * 0.65)
            }
            UIView().apply { (widthBound) in
                widthBound.addTo(scrollView) { (make) in
                    make.left.top.right.equalToSuperview()
                    make.height.equalTo(0)
                    make.width.equalTo(self)
                }
            }
        }
        
        stackView.apply { (stackView) in
            stackView.axis = .vertical
            stackView.alignment = .fill
            stackView.spacing = 10
            stackView.addTo(scrollView) { (make) in
                make.edges.equalToSuperview()
            }
        }
        
        stackView.addArrangedSubview(eventGroup)
        stackView.addArrangedSubview(relationGroup)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
