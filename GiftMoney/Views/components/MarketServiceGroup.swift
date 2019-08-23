//
//  MarketServiceGroup.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/20.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class MarketServiceHeader: UIView {
    let button = UIButton()
    let icon = UIImageView()
    init(title: String, image: UIImage?) {
        super.init(frame: .zero)
        
        icon.image = image
        icon.contentMode = .scaleAspectFit
        icon.addTo(self) { (make) in
            make.left.equalToSuperview()
            make.width.height.equalTo(25)
            make.bottom.equalTo(-5)
            make.top.equalTo(5)
        }
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.appBoldFont(ofSize: 15)
        button.addTo(self) { (make) in
            make.left.equalTo(icon.snp.right).offset(4)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class MarketServiceItem: UIView {
    let title = UILabel(textColor: UIColor.lightText, font: UIFont.appFont(ofSize: 11))
    let icon = UIImageView()
    
    init(title: String) {
        super.init(frame: .zero)
        icon.layer.cornerRadius = 3
        icon.layer.masksToBounds = true
        icon.backgroundColor = .white
        icon.addTo(self) { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(5)
            make.width.height.equalTo(6)
        }
        self.title.text = title
        self.title.numberOfLines = 0
        self.title.addTo(self) { (make) in
            make.left.equalTo(icon.snp.right).offset(3)
            make.top.equalTo(3)
            make.bottom.right.equalTo(-3)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MarketServiceGroup: UIView {
    
    let stackView = UIStackView()
    let buyButton = UIButton()
    init(header: MarketServiceHeader, items: [MarketServiceItem], showPay: Bool, isPaid: Bool = false) {
        super.init(frame: .zero)
        
        header.addTo(self) { (make) in
            make.left.equalTo(20)
            make.top.equalToSuperview()
        }
        
        stackView.apply { (stackView) in
            stackView.alignment = .leading
            stackView.axis = .vertical
            stackView.spacing = 0
            
            stackView.addTo(self) { (make) in
                make.left.equalTo(40)
                make.top.equalTo(header.snp.bottom)
                make.bottom.equalToSuperview()
            }
        }
        
        items.forEach { (item) in
            stackView.addArrangedSubview(item)
        }
        
        buyButton.apply { (button) in
            button.setTitle("购买", for: .normal)
            button.setTitleColor(UIColor.white, for: .normal)
            button.setImage(UIImage(named: "icons8-buy"), for: .normal)
            
            button.setTitle("已购买", for: .disabled)
            button.setTitleColor(UIColor.green, for: .disabled)
            button.setImage(UIImage(named: "icons8-checked"), for: .disabled)
            
            button.imageView?.contentMode = .scaleAspectFit
            
            button.addTo(self) { (make) in
                make.centerY.equalTo(header)
                make.right.equalTo(-20)
                make.left.greaterThanOrEqualTo(stackView.snp.right).offset(30)
                make.height.equalTo(35)
                make.width.equalTo(100)
            }
        }
        buyButton.setEnlargeEdge(top: 0, right: 20, bottom: 50, left: 400)
        buyButton.isHidden = !showPay
        buyButton.isEnabled = !isPaid
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
