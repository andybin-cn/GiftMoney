//
//  MarketVC.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/20.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class MarketVC: BaseViewController {
    
    let scrollView = UIScrollView()
    let closeButton = UIButton()
    let recoverButton = UIButton()
    let stackView = UIStackView()
    
    let freeGroup: MarketServiceGroup
    let vip1Group: MarketServiceGroup
    let vip2Group: MarketServiceGroup
    
    init() {
        let freeHeader = MarketServiceHeader(title: "免费试用", image: UIImage(named: "icons8-trial_version")?.ui_renderImage(tintColor: UIColor.white))
        let freeItems: [MarketServiceItem] = [
            MarketServiceItem(title: "自定义关系 4个"),
            MarketServiceItem(title: "自定义事件 2个"),
            MarketServiceItem(title: "每条记录最多添加 1张 图片或视频"),
        ]
        freeGroup = MarketServiceGroup(header: freeHeader, items: freeItems, showPay: false)
        
        let vip1Header = MarketServiceHeader(title: "购买【白银Vip】  （¥2元）", image: UIImage(named: "icons8-vip")?.ui_renderImage(tintColor: UIColor.appMainYellow))
        let vip1Items: [MarketServiceItem] = [
            MarketServiceItem(title: "自定义关系 8个"),
            MarketServiceItem(title: "自定义事件 4个"),
            MarketServiceItem(title: "解锁批量修改事件名称"),
            MarketServiceItem(title: "每条记录最多添加 8 张图片或视频"),
        ]
        vip1Group = MarketServiceGroup(header: vip1Header, items: vip1Items, showPay: true)
        
        let vip2Header = MarketServiceHeader(title: "购买【黄金Vip】  （¥12元）", image: UIImage(named: "icons8-vip")?.ui_renderImage(tintColor: UIColor.from(hexString: "#FF6100")))
        let vip2Items: [MarketServiceItem] = [
            MarketServiceItem(title: "白银Vip的所有功能"),
            MarketServiceItem(title: "数据导入导出功能"),
            MarketServiceItem(title: "不限自定义关系个数"),
            MarketServiceItem(title: "不限自定义事件个数"),
            MarketServiceItem(title: "不限图片或视频个数"),
        ]
        vip2Group = MarketServiceGroup(header: vip2Header, items: vip2Items, showPay: true)
        
        
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
        stackView.addArrangedSubview(freeGroup)
        stackView.addArrangedSubview(vip1Group)
        stackView.addArrangedSubview(vip2Group)
        
        closeButton.apply { (button) in
            button.setTitle("关闭", for: UIControl.State.normal)
            button.addTarget(self, action: #selector(onCloseButtonTapped), for: .touchUpInside)
            button.addTo(view) { (make) in
                make.left.equalTo(15)
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            }
        }
        
        recoverButton.apply { (button) in
            button.setTitle("恢复购买", for: UIControl.State.normal)
            button.addTarget(self, action: #selector(onRecoverButtonTapped), for: .touchUpInside)
            button.addTo(view) { (make) in
                make.right.equalTo(-15)
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            }
        }
    }
    
    @objc func onCloseButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onRecoverButtonTapped() {
        
    }
    
    
}
