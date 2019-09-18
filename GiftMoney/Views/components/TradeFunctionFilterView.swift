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
    var startTime: NSDate?
    var endTime: NSDate?
    var minAmount: Float?
    var maxAmount: Float?
}


class TradeFunctionFilterView: UIView {
    
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    var eventGroup: TradeFunctionContainerView
    var relationGroup: TradeFunctionContainerView
    var dateGroup: TradeFunctionContainerView
    var filteroptions: FilterOption {
        let options = FilterOption()
        if let eventsBody = eventGroup.body as? TradeFunctionButtonsView {
             options.events = eventsBody.selectedItems as? [Event] ?? [Event]()
        }
        if let relationsBody = relationGroup.body as? TradeFunctionButtonsView {
            options.relations = relationsBody.selectedItems as? [Relationship] ?? [Relationship]()
        }
        if let body = dateGroup.body as? TradeFunctionTimeView {
            options.startTime = body.startTime
            options.endTime = body.endTime
        }
        return options
    }
    
    init() {
        eventGroup = TradeFunctionContainerView(title: "事件类型", body: TradeFunctionButtonsView(items: OptionalService.shared.latestusedEvents, selectedItems: []))
        relationGroup = TradeFunctionContainerView(title: "关系", body: TradeFunctionButtonsView(items: OptionalService.shared.latestusedRelationships, selectedItems: []))
        dateGroup = TradeFunctionContainerView(title: "时间区间", body: TradeFunctionTimeView())
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
        stackView.addArrangedSubview(dateGroup)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset() {
        (eventGroup.body as? TradeFunctionButtonsView)?.resetWith(items: OptionalService.shared.latestusedEvents)
        (relationGroup.body as? TradeFunctionButtonsView)?.resetWith(items: OptionalService.shared.latestusedRelationships)
        (dateGroup.body as? TradeFunctionTimeView)?.reset()
    }
    
    func refreshItems() {
        (eventGroup.body as? TradeFunctionButtonsView)?.items = OptionalService.shared.latestusedEvents
        (relationGroup.body as? TradeFunctionButtonsView)?.items = OptionalService.shared.latestusedRelationships
    }
}
