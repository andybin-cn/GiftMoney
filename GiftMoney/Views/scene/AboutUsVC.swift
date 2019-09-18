//
//  AboutUsVC.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/23.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import UIKit

class AboutUsVC: BaseViewController {
    
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.apply { (scrollView) in
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.alwaysBounceVertical = true
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
            stackView.alignment = .center
            stackView.spacing = 10
            
            stackView.addTo(scrollView) { (make) in
                make.top.equalTo(40)
                make.left.equalTo(20)
                make.right.equalTo(-20)
                make.bottom.equalTo(-40)
            }
        }
        
        let logo = UIImageView(image: UIImage(named: "logo"))
        logo.snp.makeConstraints { (make) in
            make.width.height.equalTo(200)
        }
        stackView.addArrangedSubview(logo)
        
        stackView.addArrangedSubview(UILabel(textColor: .appDarkText, font: .appBoldFont(ofSize: 20), textAlignment: .center, text: "礼金小助手"))
        
        let infoDic = Bundle.main.infoDictionary
        let appVersion = infoDic?["CFBundleShortVersionString"] ?? "0.0"
        let appBuildVersion = infoDic?["CFBundleVersion"] ?? "0"
        
        stackView.addArrangedSubview(UILabel(textColor: .appGrayText, font: .appFont(ofSize: 13), textAlignment: .center, text: "版本: \(appVersion)(\(appBuildVersion))"))
        
        let label1 = UILabel(textColor: .appGrayText, font: .appFont(ofSize: 14), textAlignment: .left, text: "1.我们没有后台服务端，所以不会收集用户的任何数据，也无法查看您的数据记录。请放心使用！\n\n2.数据完全保存在本地（备份数据会保存在您Apple账号的iCloud中），对数据进行了严格的加密保护，保证数据的安全可靠！")
        label1.numberOfLines = 0
        label1.lineBreakMode = .byWordWrapping
        stackView.addArrangedSubview(label1)
        
        let label2 = UILabel(textColor: .appGrayText, font: .appFont(ofSize: 14), textAlignment: .center, text: "\n\n如遇到任何问题，请发送邮件至：reciprocityApp@163.com\n我们会尽快与您联系")
        label2.numberOfLines = 0
        label2.lineBreakMode = .byWordWrapping
        stackView.addArrangedSubview(label2)
    }
    
}
