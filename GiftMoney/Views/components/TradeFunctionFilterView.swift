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
    var eventGroup: TradeFunctionContainerView
    var relationGroup: TradeFunctionContainerView
    var filteroptions: FilterOption {
        let options = FilterOption()
        if let eventsBody = eventGroup.body as? TradeFunctionButtonsView {
             options.events = eventsBody.selectedItems as? [Event] ?? [Event]()
        }
        if let relationsBody = relationGroup.body as? TradeFunctionButtonsView {
            options.relations = relationsBody.selectedItems as? [Relationship] ?? [Relationship]()
        }
        return options
    }
    
    init() {
        eventGroup = TradeFunctionContainerView(title: "事件类型", body: TradeFunctionButtonsView(items: Event.allEventNames, selectedIndex: []))
        relationGroup = TradeFunctionContainerView(title: "关系", body: TradeFunctionButtonsView(items: Relationship.latestusedRelationships, selectedIndex: []))
        super.init(frame: .zero)
        
        scrollView.apply { (scrollView) in
            scrollView.alwaysBounceVertical = true
            scrollView.alwaysBounceHorizontal = false
            scrollView.backgroundColor = UIColor.white
            scrollView.addTo(self) { (make) in
                make.edges.equalToSuperview()
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
    
    func reset() {
        stackView.removeArrangedSubview(eventGroup)
        eventGroup.removeFromSuperview()
        stackView.removeArrangedSubview(relationGroup)
        relationGroup.removeFromSuperview()
        
        
        eventGroup = TradeFunctionContainerView(title: "事件类型", body: TradeFunctionButtonsView(items: Event.allEventNames, selectedIndex: []))
        relationGroup = TradeFunctionContainerView(title: "关系", body: TradeFunctionButtonsView(items: Relationship.latestusedRelationships, selectedIndex: []))
        
        stackView.addArrangedSubview(eventGroup)
        stackView.addArrangedSubview(relationGroup)
    }
}
