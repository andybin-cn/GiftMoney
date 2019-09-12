//
//  TradeCell.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/7.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Common

class TradeCell: UITableViewCell {
    let iconLabel = UILabel()
    let nameLabel = UILabel()
    let eventLabel = UILabel()
    let timeLabel = UILabel()
    let gitfLabel = UILabel()
    let moneyLabel = UILabel()
    let uploadButton = UIButton()
    
    var trade: Trade?
    
    var disposeBag: DisposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func setupSubviews() {
        accessoryType = .disclosureIndicator
        
        iconLabel.apply { (label) in
            label.font = UIFont.appBoldFont(ofSize: 25)
            label.textColor = .white
            label.layer.cornerRadius = 20
            label.clipsToBounds = true
            label.layer.borderWidth = 1
            label.textAlignment = .center
            label.backgroundColor = .appSecondaryYellow
            label.layer.borderColor = UIColor.appMainRed.cgColor
            
            label.addTo(contentView) { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(15)
                make.height.width.equalTo(40)
                make.height.lessThanOrEqualToSuperview().inset(20)
            }
        }
        
        nameLabel.apply { (label) in
            label.font = UIFont.appFont(ofSize: 13)
            label.textColor = .appDarkText
            
            label.addTo(contentView) { (make) in
                make.top.greaterThanOrEqualToSuperview().offset(8)
                make.left.equalTo(iconLabel.snp.right).offset(10)
            }
        }
        eventLabel.apply { (label) in
            label.font = UIFont.appFont(ofSize: 13)
            label.textColor = .appGrayText
            
            label.addTo(contentView) { (make) in
                make.top.equalTo(nameLabel.snp.bottom).offset(5)
                make.left.equalTo(nameLabel.snp.left)
            }
        }
        timeLabel.apply { (label) in
            label.font = UIFont.appFont(ofSize: 11)
            label.textColor = .appGrayText
            
            label.addTo(contentView) { (make) in
                make.top.equalTo(eventLabel.snp.bottom).offset(5)
                make.left.equalTo(nameLabel.snp.left)
                make.bottom.lessThanOrEqualToSuperview().inset(8)
            }
        }
        let stackView = UIStackView().then { (stackView) in
            stackView.axis = .vertical
            stackView.spacing = 6
            stackView.alignment = .fill
            stackView.addTo(contentView) { (make) in
                make.centerY.equalToSuperview()
                make.right.equalTo(-40)
            }
        }
        gitfLabel.apply { (label) in
            label.font = UIFont.appFont(ofSize: 15)
            label.textColor = .appSecondaryRed
            label.textAlignment = .right
        }
        moneyLabel.apply { (label) in
            label.font = UIFont.appFont(ofSize: 15)
            label.textColor = .appSecondaryRed
            label.textAlignment = .right
        }
        
        stackView.addArrangedSubview(moneyLabel)
        stackView.addArrangedSubview(gitfLabel)
        
        uploadButton.titleLabel?.font = UIFont.appFont(ofSize: 10)
        uploadButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
//        uploadButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        uploadButton.addTo(self) { (make) in
            make.top.right.equalToSuperview()
        }
        uploadButton.addTarget(self, action: #selector(onUploadButtonTapped), for: .touchUpInside)
    }
    
    func configerUI(trade: Trade) {
        self.trade = trade
        guard let type = trade.type else {
            return
        }
        if type == .inAccount {
            iconLabel.text = "收"
            iconLabel.backgroundColor = UIColor.appSecondaryYellow
            iconLabel.layer.borderColor = UIColor.appMainRed.cgColor
            iconLabel.textColor = .appMainRed
        } else {
            iconLabel.backgroundColor = UIColor.appMainRed
            iconLabel.layer.borderColor = UIColor.appSecondaryYellow.cgColor
            iconLabel.text = "支"
            iconLabel.textColor = .white
        }
        
        nameLabel.text = trade.name
        eventLabel.text = trade.eventName
        timeLabel.text = trade.eventTime.toString(withFormat: "yyyy-MM-dd")
        gitfLabel.text = "礼物共    \(trade.giftCount)份"
        moneyLabel.text = String.init(format: "红包共 ¥%0.0f元", trade.totalMoney)
        
        self.refreshUploadStatus()
    }
    
    func refreshUploadStatus() {
        guard let trade = trade else {
            return
        }
        let uploadItem = CloudBackupQueue.shared.uploadItem(forTradeID: trade.id)
        uploadButton.isUserInteractionEnabled = false
        if !trade.hasBackupToCloud {
            if let uploadItem = uploadItem {
                uploadButton.setTitle("正在同步", for: .normal)
                uploadButton.setImage(UIImage(named: "icons8-cloud_refresh")?.ui_resizeImage(to: CGSize(width: 16, height: 16)), for: .normal)
                uploadButton.setTitleColor(UIColor.appSecondaryGray, for: .normal)
                uploadItem.subscribe(onError: { [unowned self] (_) in
                    self.uploadButton.isUserInteractionEnabled = true
                    self.uploadButton.setTitle("点击重试", for: .normal)
                    self.uploadButton.setImage(UIImage(named: "icons8-error_cloud")?.ui_resizeImage(to: CGSize(width: 16, height: 16)), for: .normal)
                    self.uploadButton.setTitleColor(UIColor.appSecondaryRed, for: .normal)
                }, onCompleted: { [unowned self] in
                    self.uploadButton.isUserInteractionEnabled = false
                    self.uploadButton.setTitle("已同步", for: .normal)
                    self.uploadButton.setImage(UIImage(named: "icons8-cloud_checked")?.ui_resizeImage(to: CGSize(width: 16, height: 16)), for: .normal)
                    self.uploadButton.setTitleColor(UIColor.appSecondaryBlue, for: .normal)
                }).disposed(by: disposeBag)
            } else {
                uploadButton.isUserInteractionEnabled = true
                uploadButton.setTitle("同步至iCloud", for: .normal)
                uploadButton.setImage(UIImage(named: "icons8-upload_to_cloud")?.ui_resizeImage(to: CGSize(width: 16, height: 16)), for: .normal)
                uploadButton.setTitleColor(UIColor.appSecondaryBlue, for: .normal)
            }
        } else {
            uploadButton.setTitle("已同步", for: .normal)
            uploadButton.setImage(UIImage(named: "icons8-cloud_checked")?.ui_resizeImage(to: CGSize(width: 16, height: 16)), for: .normal)
            uploadButton.setTitleColor(UIColor.appSecondaryBlue, for: .normal)
        }
    }
    
    @objc func onUploadButtonTapped() {
        print("onUploadButtonTapped")
        let controller = self.firstViewController ?? MainTabViewController.shared
        guard let trade = trade, MarketManager.shared.checkAuth(type: .autoSyncToiCloud, controller: controller) else {
            return
        }
        _ = CloudBackupQueue.shared.backupTradeInQueue(tradeID: trade.id)
        self.refreshUploadStatus()
    }
}
