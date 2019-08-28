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
        
        stackView.addArrangedSubview(UILabel(textColor: .appDarkText, font: .appBoldFont(ofSize: 20), textAlignment: .center, text: "礼尚往来"))
        
        let label1 = UILabel(textColor: .appGrayText, font: .appFont(ofSize: 14), textAlignment: .left, text: "\n我们的App所有的数据都是保存在本机和Apple Cloud上，保证数据的绝对安全，请放心使用！")
        label1.numberOfLines = 0
        label1.lineBreakMode = .byWordWrapping
        stackView.addArrangedSubview(label1)
        
        let label2 = UILabel(textColor: .appGrayText, font: .appFont(ofSize: 14), textAlignment: .center, text: "\n\n如遇到任何问题，请发送邮件至：reciprocityApp@163.com\n我们会尽快与您联系")
        label2.numberOfLines = 0
        label2.lineBreakMode = .byWordWrapping
        stackView.addArrangedSubview(label2)
    }
    
}
