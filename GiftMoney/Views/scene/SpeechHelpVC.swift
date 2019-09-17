//
//  SpeechHelpVC.swift
//  GiftMoney
//
//  Created by binea on 2019/9/17.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import SnapKit

class SpeechHelpVC: BaseViewController {
    let scrollView = UIScrollView()
    let closeButton = UIButton()
    let stackView = UIStackView()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = UIColor.purple.withAlphaComponent(0.2)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurEffect = UIBlurEffect.init(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.9
        blurEffectView.addTo(view) { (make) in
            make.edges.equalToSuperview()
        }
        
        scrollView.apply { (scrollView) in
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.alwaysBounceVertical = true
            scrollView.backgroundColor = .clear
            scrollView.addTo(self.view) { (make) in
                make.edges.equalToSuperview()
            }
            
            UIView().apply { (widthView) in
                widthView.addTo(scrollView) { (make) in
                    make.left.right.top.equalToSuperview()
                    make.height.equalTo(0)
                    make.width.equalTo(self.view)
                }
            }
        }
        
        stackView.apply { (stackView) in
            stackView.axis = .vertical
            stackView.alignment = .fill
            stackView.spacing = 15
            stackView.addTo(scrollView) { (make) in
                make.top.equalTo(100)
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview().offset(-40).priority(ConstraintPriority.low)
            }
        }
        
        closeButton.apply { (button) in
            button.setTitle("关闭", for: UIControl.State.normal)
            button.addTarget(self, action: #selector(onCloseButtonTapped), for: .touchUpInside)
            button.addTo(view) { (make) in
                make.right.equalTo(-15)
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            }
        }
        
        let examplesHeader = MarketServiceHeader(title: "语音录入例子：", image: nil)
        let exampleItems: [MarketServiceItem] = [
            MarketServiceItem(title: "结婚收到李萌萌同学200元红包"),
            MarketServiceItem(title: "李萌萌200元"),
            MarketServiceItem(title: "李萌萌同学结婚送给她200元红包")
        ]
        let examplesGroup = MarketServiceGroup(header: examplesHeader, items: exampleItems, showPay: false)
        
        let tipsHeader = MarketServiceHeader(title: "使用技巧：", image: nil)
        let tipsItems: [MarketServiceItem] = [
            MarketServiceItem(title: "尽量放慢语速，大声准确的说出关键信息。"),
            MarketServiceItem(title: "从【收到的】事件详情界面进行添加可以直接带入事件信息。"),
            MarketServiceItem(title: "从【收到的】事件列表界面进行添加可以直接带入事件信息。")
        ]
        let tipsGroup = MarketServiceGroup(header: tipsHeader, items: tipsItems, showPay: false)
        
        stackView.addArrangedSubview(examplesGroup)
        stackView.addArrangedSubview(tipsGroup)
    }
    
    @objc func onCloseButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}
