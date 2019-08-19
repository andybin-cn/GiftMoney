//
//  MineTextRow.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/19.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class MineTextRow: UIButton {
    let icon = UIImageView()
    let label = UILabel(textColor: UIColor.appText, fontSize: 14)
    let subLabel = UILabel(textColor: UIColor.appGrayText, fontSize: 12)
    let accessoryView = UIImageView(image: UIImage(named: "icons8-forward"))
    let loadingView = UIActivityIndicatorView()
    
    init(title: String, image: UIImage?) {
        label.text = title
        icon.image = image
        super.init(frame: CGRect.zero)
        icon.addTo(self) { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
            make.width.height.equalTo(25)
        }
        
        label.addTo(self) { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(icon.snp.right).offset(8)
        }
        
        accessoryView.addTo(self) { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-15)
            make.width.height.equalTo(20)
        }
        
        loadingView.isHidden = true
        loadingView.addTo(self) { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-15)
            make.width.height.equalTo(20)
        }
        
        subLabel.addTo(self) { (make) in
            make.right.equalTo(loadingView.snp.left).offset(-10)
            make.centerY.equalToSuperview()
        }
        
        self.backgroundColor = .white
        self.snp.makeConstraints { (make) in
            make.height.equalTo(40)
        }
//        setBackgroundImage(UIColor.lightGray.toImage(), for: UIControl.State.highlighted)
    }
    
    func showLoadingView() {
        accessoryView.isHidden = true
        loadingView.isHidden = false
        loadingView.startAnimating()
    }
    func hideLoadingView() {
        accessoryView.isHidden = false
        loadingView.isHidden = true
        loadingView.stopAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
