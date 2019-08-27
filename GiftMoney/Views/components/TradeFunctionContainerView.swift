//
//  TradeFunctionContainerView.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/27.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation


class TradeFunctionContainerView: UIView {
    let header = UIView()
    let titleLabel = UILabel(textColor: UIColor.appDarkText, font: .appFont(ofSize: 15))
    let rightIcon = UIImageView(image: UIImage(named: "icons8-expand_arrow"))
    let body: UIView
    var expanded = false {
        didSet {
            self.snp.remakeConstraints({ (make) in
                if expanded {
                    make.bottom.equalTo(body.snp.bottom).offset(15)
                    rightIcon.image = UIImage(named: "icons8-collapse_arrow")
                } else {
                    make.height.equalTo(100)
                    rightIcon.image = UIImage(named: "icons8-expand_arrow")
                }
            })
            UIView.animate(withDuration: 0.25) {
                self.layoutIfNeeded()
            }
        }
    }
    
    init(title: String, body: UIView, showExpand: Bool = false) {
        self.body = body
        super.init(frame: .zero)
        
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        
        header.apply { (header) in
            if showExpand {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onHeaderTapped))
                header.isUserInteractionEnabled = true
                header.addGestureRecognizer(tapGesture)
            }
            header.addTo(self) { (make) in
                make.left.top.right.equalToSuperview()
                make.height.equalTo(35)
            }
        }
        
        titleLabel.apply { (label) in
            label.text = title
            label.addTo(header) { (make) in
                make.centerY.equalTo(header)
                make.left.equalTo(20)
            }
        }
        rightIcon.apply { (icon) in
            if showExpand {
                icon.addTo(header) { (make) in
                    make.right.equalTo(-20)
                    make.centerY.equalToSuperview()
                }
            }
        }
        
        body.addTo(self) { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(header.snp.bottom)
        }
        if showExpand {
            self.snp.makeConstraints { (make) in
                make.height.equalTo(100)
            }
        } else {
            self.snp.makeConstraints { (make) in
                make.bottom.equalTo(body.snp.bottom).offset(15)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onHeaderTapped() {
        expanded = !expanded
    }
}
