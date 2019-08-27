//
//  TradeFuntionSortView.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/27.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation

enum TradeFuntionSort {
    case timeAscending
    case timeDescending
    case amountAscending
    case amountDescending
}

extension TradeFuntionSort: TradeFunctionButtonItem {
    var title: String {
        switch self {
        case .timeAscending:
            return "时间升序"
        case .timeDescending:
            return "时间降序"
        case .amountAscending:
            return "金额升序"
        case .amountDescending:
            return "金额降序"
        }
    }
}


class TradeFuntionSortView: UIView {
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    let items: [TradeFuntionSort] = [.timeDescending, .timeAscending, .amountAscending, .amountDescending]
    var sortGroup: TradeFunctionContainerView
    
    var sortType: TradeFuntionSort {
        if let body = sortGroup.body as? TradeFunctionButtonsView {
            let selectedItems = body.selectedItems as? [TradeFuntionSort] ?? [TradeFuntionSort]()
            return selectedItems.first ?? items.first!
        }
        return items.first!
    }
    init() {
        sortGroup = TradeFunctionContainerView(title: "排序方式", body: TradeFunctionButtonsView(items: items, selectedIndex: [0], isMultiple: false))
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
        
        stackView.addArrangedSubview(sortGroup)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset() {
        stackView.removeArrangedSubview(sortGroup)
        sortGroup.removeFromSuperview()
        
        sortGroup = TradeFunctionContainerView(title: "排序方式", body: TradeFunctionButtonsView(items: items, selectedIndex: [0], isMultiple: false))
        stackView.addArrangedSubview(sortGroup)
    }
}
