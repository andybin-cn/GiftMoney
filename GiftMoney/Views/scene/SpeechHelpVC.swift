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
                make.bottom.lessThanOrEqualTo(-40).priority(ConstraintPriority.low)
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
        
        
        let experienceView = UIView().then { (experienceView) in
            let image = MarketManager.shared.currentLevel == .free ? UIImage(named: "icons8-info")?.ui_renderImage(tintColor: .appSecondaryYellow) : UIImage(named: "icons8-approval")
            let icon = UIImageView(image: image)
            icon.addTo(experienceView, layout: { (make) in
                make.left.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.height.equalTo(26)
            })
            
            UILabel().apply({ (label) in
                label.numberOfLines = 0
                label.lineBreakMode = .byWordWrapping
                label.attributedText = authorityDesc
                label.textAlignment = .left
                label.addTo(experienceView, layout: { (make) in
                    make.left.equalTo(icon.snp.right).offset(5)
                    make.centerY.equalToSuperview()
                    make.right.equalTo(0)
                    make.bottom.lessThanOrEqualToSuperview()
                })
            })
            
            experienceView.addTo(scrollView, layout: { (make) in
                make.left.equalTo(20)
                make.top.equalTo(stackView.snp.bottom).offset(40)
                make.right.equalTo(-20)
                make.bottom.lessThanOrEqualTo(-40).priority(.low)
            })
        }
        
        
        if MarketManager.shared.currentLevel == .free {
            let buyButton = UIButton()
            buyButton.setTitle("立即获得无限使用次数", for: .normal)
            buyButton.setBackgroundImage(UIColor.appSecondaryGray.toImage(), for: .normal)
            buyButton.setTitleColor(.appMainRed, for: .normal)
            buyButton.layer.cornerRadius = 4
            buyButton.layer.masksToBounds = true
            buyButton.addTarget(self, action: #selector(onBuyButtonTapped), for: .touchUpInside)
            
            buyButton.addTo(scrollView) { (make) in
                make.left.equalTo(20)
                make.top.equalTo(experienceView.snp.bottom).offset(50)
                make.right.equalTo(-20)
                make.bottom.lessThanOrEqualTo(-60).priority(.low)
                make.height.equalTo(35)
            }
        }
        
    }
    
    @objc func onBuyButtonTapped() {
        self.present(MarketVC(superVC: self), animated: true, completion: nil)
    }
    
    var authorityDesc: NSAttributedString {
        let attrString = NSMutableAttributedString()
//        let paragraphStyle = NSMutableParagraphStyle()
        if MarketManager.shared.currentLevel == .free {
            attrString.append(NSAttributedString(string: "您的【语音识别录入】功能剩余", attributes: [NSAttributedString.Key.font : UIFont.appFont(ofSize: 13), NSAttributedString.Key.foregroundColor : UIColor.appSecondaryYellow]))
            attrString.append(NSAttributedString(string: "\(MarketManager.shared.speechRecognizedLimit - MarketManager.shared.speechRecognizedCount)", attributes: [NSAttributedString.Key.font : UIFont.appBoldFont(ofSize: 20), NSAttributedString.Key.foregroundColor : UIColor.appMainRed]))
            attrString.append(NSAttributedString(string: " 次免费体验次数(识别成功算一次)", attributes: [NSAttributedString.Key.font : UIFont.appFont(ofSize: 13), NSAttributedString.Key.foregroundColor : UIColor.appSecondaryYellow]))
        } else {
            attrString.append(NSAttributedString(string: "恭喜你！您已可以无限制的使用【语音识别录入】功能啦！", attributes: [NSAttributedString.Key.font : UIFont.appFont(ofSize: 13), NSAttributedString.Key.foregroundColor : UIColor.appSecondaryBlue]))
            
        }
//        paragraphStyle.lineSpacing = 40
//        attrString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        
        return attrString
    }
    
    
    @objc func onCloseButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}
