//
//  TradeFuntionSortView.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/27.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation


class TradeFuntionSortView: UIView {
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    
    init() {
        super.init(frame: .zero)
        
        let sortGroup = TradeFunctionContainerView(title: "排序方式", body: TradeFunctionButtonsView(items: ["时间升序", "时间降序", "金额升序", "金额降序"], selectedIndex: [2]))
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
        
        stackView.addArrangedSubview(sortGroup)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
