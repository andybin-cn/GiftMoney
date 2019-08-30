//
//  InviteCodeVC.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/28.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import SnapKit


class InviteCodeVC: BaseViewController {
    
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    let inviteCode = InviteManager.shared.inviteCode ?? ""
    let inviteCount = InviteManager.shared.invitedCount
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "邀请好友解锁新功能"
        
        scrollView.apply { (scrollView) in
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.alwaysBounceVertical = true
            scrollView.backgroundColor = UIColor.appGrayBackground
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
            stackView.spacing = 20
            stackView.addTo(scrollView) { (make) in
                make.top.left.equalTo(20)
                make.right.equalTo(-20)
                make.bottom.equalToSuperview().offset(-40).priority(ConstraintPriority.low)
            }
        }
        
        let label1 = UILabel(textColor: .appDarkText, font: .appFont(ofSize: 18), textAlignment: .left, text: "成功邀请 5 位好友，解锁【黄金VIP】所有功能")
        label1.numberOfLines = 0
        label1.lineBreakMode = .byWordWrapping
        
        let label2 = UILabel(textColor: .appDarkText, font: .appFont(ofSize: 18), textAlignment: .left, text: "成功邀请 30 位好友，解锁【钻石VIP】所有功能")
        label2.numberOfLines = 0
        label2.lineBreakMode = .byWordWrapping
        
        let label3 = UILabel(textColor: .appGrayText, font: .appFont(ofSize: 13), textAlignment: .left, text: "我的邀请码【\(inviteCode)】,告诉好友下载App后，填写你的邀请码就可以了。")
        label3.numberOfLines = 0
        label3.lineBreakMode = .byWordWrapping
        
        
        let label4 = UILabel(textColor: .appDarkText, font: .appFont(ofSize: 18), textAlignment: .left, text: "您已成功邀请 \(inviteCount) 位好友!")
        label4.numberOfLines = 0
        label4.lineBreakMode = .byWordWrapping
        
        let buttons = UIStackView().then { (stackView) in
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.spacing = 20
        }
        let button1 = UIButton().then { (button) in
            button.setTitle("复制邀请码", for: .normal)
            button.setTitleColor(.appSecondaryYellow, for: .normal)
            button.setBackgroundImage(UIColor.appSecondaryRed.toImage(), for: .normal)
            button.layer.cornerRadius = 17
            button.layer.masksToBounds = true
            
            button.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
        }
        
        let button2 = UIButton().then { (button) in
            button.setTitle("立即邀请", for: .normal)
            button.setTitleColor(.appMainRed, for: .normal)
            button.layer.cornerRadius = 17
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.appMainRed.cgColor
            button.layer.masksToBounds = true
            
            button.addTarget(self, action: #selector(inviteButtonTapped), for: .touchUpInside)
        }
        
        buttons.addArrangedSubview(button1)
        buttons.addArrangedSubview(button2)
        
        stackView.addArrangedSubview(label1)
        stackView.addArrangedSubview(label2)
        stackView.addArrangedSubview(label3)
        stackView.addArrangedSubview(label4)
        stackView.addArrangedSubview(buttons)
        
    }
    
    @objc func inviteButtonTapped() {
        let controller = UIActivityViewController(activityItems: ["给你推荐一款实用App，记得填写我的邀请码：\(inviteCode)", URL(string: "http://www.baidu.com")!], applicationActivities: nil)
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc func copyButtonTapped() {
        
    }
}
